module "iam" {
  source = "./modules/iam"

  cluster_name = var.cluster.name

  aws_region_short = var.aws_region_short

  create_node_group_iam_role = false

  kms_key_administrators = var.kms_key_administrators
}

module "eks" {
  source = "terraform-aws-modules/eks/aws"

  version = "20.5.0"

  cluster_name                   = var.cluster.name
  cluster_version                = var.cluster.version
  cluster_endpoint_public_access = var.cluster.endpoint_public_access

  enable_irsa  = true
  iam_role_arn = module.iam.cluster_iam_role_arn

  create_kms_key = false
  cluster_encryption_config = {
    provider_key_arn = module.iam.kms_key_arn
    resources        = ["secrets"]
  }

  # Gives Terraform identity admin access to cluster which will
  # allow deploying resources (Karpenter) into the cluster
  enable_cluster_creator_admin_permissions = true

  cluster_addons = {
    coredns = {
      configuration_values = jsonencode({
        computeType = "Fargate"
        # Ensure that we fully utilize the minimum amount of resources that are supplied by
        # Fargate https://docs.aws.amazon.com/eks/latest/userguide/fargate-pod-configuration.html
        # Fargate adds 256 MB to each pod's memory reservation for the required Kubernetes
        # components (kubelet, kube-proxy, and containerd). Fargate rounds up to the following
        # compute configuration that most closely matches the sum of vCPU and memory requests in
        # order to ensure pods always have the resources that they need to run.
        resources = {
          limits = {
            cpu = "0.25"
            # We are targeting the smallest Task size of 512Mb, so we subtract 256Mb from the
            # request/limit to ensure we can fit within that task
            memory = "256M"
          }
          requests = {
            cpu = "0.25"
            # We are targeting the smallest Task size of 512Mb, so we subtract 256Mb from the
            # request/limit to ensure we can fit within that task
            memory = "256M"
          }
        }
      })
    }
    kube-proxy = {}
    vpc-cni    = {}
  }

  vpc_id                   = var.network.vpc_id
  subnet_ids               = var.network.subnet_ids
  control_plane_subnet_ids = var.network.control_plane_subnet_ids

  # Fargate profiles use the cluster primary security group so these are not utilized
  create_cluster_security_group = false
  create_node_security_group    = false

  fargate_profiles = local.fargate_profiles

  tags = merge(var.tags, {
    # NOTE - if creating multiple security groups with this module, only tag the
    # security group that Karpenter should utilize with the following tag
    # (i.e. - at most, only one security group should have this tag in your account)
    "karpenter.sh/discovery" = var.cluster.name
  })
}

module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  version = "20.5.0"

  cluster_name = module.eks.cluster_name

  # EKS Fargate currently does not support Pod Identity
  enable_irsa            = true
  irsa_oidc_provider_arn = module.eks.oidc_provider_arn

  # Used to attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  tags = var.tags
}

module "eks_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "20.5.0"

  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = "arn:aws:iam::478986666586:role/TrackitMonitoringAdmin"
      username = "trackit-eks-admin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::478986666586:role/adn-admins"
      username = "adn-eks-admin"
      groups   = ["system:masters"]
    },
    {
      rolearn  = module.karpenter.iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups   = ["system:bootstrappers", "system:nodes"]
    }
  ]

  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::478986666586:user/trackit-eks"
      username = "terraform-account"
      groups   = ["system:masters"]
    }
  ]
}


resource "helm_release" "karpenter" {
  namespace           = "karpenter"
  create_namespace    = true
  name                = "karpenter"
  repository          = "oci://public.ecr.aws/karpenter"
  repository_username = var.ecr_token.user_name
  repository_password = var.ecr_token.password
  chart               = "karpenter"
  version             = "v0.34.0"
  wait                = false

  values = [
    <<-EOT
    settings:
      clusterName: ${module.eks.cluster_name}
      clusterEndpoint: ${module.eks.cluster_endpoint}
      interruptionQueue: ${module.karpenter.queue_name}
    serviceAccount:
      annotations:
        eks.amazonaws.com/role-arn: ${module.karpenter.iam_role_arn}
    EOT
  ]

  depends_on = [
    module.eks_auth,
    module.karpenter
  ]
}

resource "kubectl_manifest" "karpenter_node_class" {
  yaml_body = <<-YAML
    apiVersion: karpenter.k8s.aws/v1beta1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiFamily: AL2
      role: ${module.karpenter.node_iam_role_name}
      subnetSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${module.eks.cluster_name}
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${module.eks.cluster_name}
      tags:
        karpenter.sh/discovery: ${module.eks.cluster_name}
  YAML

  depends_on = [
    module.eks_auth
  ]
}

resource "kubectl_manifest" "karpenter_node_pool" {
  yaml_body = <<-YAML
    apiVersion: karpenter.sh/v1beta1
    kind: NodePool
    metadata:
      name: default
    spec:
      template:
        spec:
          nodeClassRef:
            name: default
          requirements:
            - key: "karpenter.k8s.aws/instance-category"
              operator: In
              values: ["c", "m", "r"]
            - key: "karpenter.k8s.aws/instance-cpu"
              operator: In
              values: ["4", "8", "16", "32"]
            - key: "karpenter.k8s.aws/instance-hypervisor"
              operator: In
              values: ["nitro"]
            - key: "karpenter.k8s.aws/instance-generation"
              operator: Gt
              values: ["2"]
      limits:
        cpu: 1000
      disruption:
        consolidationPolicy: WhenEmpty
        consolidateAfter: 30s
  YAML

  depends_on = [
    module.eks_auth
  ]
}
