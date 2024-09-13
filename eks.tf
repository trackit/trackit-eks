module "iam" {
  source = "./modules/iam"

  cluster_name = var.cluster.name

  aws_region_short = var.aws_region_short

  create_node_group_iam_role = false

  kms_key_administrators = var.kms_key_administrators
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.20.0"

  # create = var.create

  node_security_group_use_name_prefix    = true
  cluster_security_group_use_name_prefix = true

  cluster_name    = var.cluster.name
  cluster_version = var.cluster.version || "1.31"

  vpc_id     = var.network.vpc_id
  subnet_ids = var.network.subnet_ids

  enable_irsa                     = true
  cluster_endpoint_private_access = true

  create_iam_role = true

  authentication_mode                      = "API_AND_CONFIG_MAP"
  enable_cluster_creator_admin_permissions = true
  # access_entries = merge(
  #   { for rolearn in lookup(local.admin_role_arns_customs, local.account_id, local.admin_role_arns_default) :
  #     rolearn => {
  #       principal_arn = rolearn
  #       type          = "STANDARD"
  #       policy_associations = {
  #         admin = {
  #           policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  #           access_scope = {
  #             type = "cluster"
  #           }
  #         }
  #       }
  #     }
  # }, var.access_entries)

  # Fargate profiles use the cluster primary security group so these are not utilized
  create_cluster_security_group         = true
  cluster_additional_security_group_ids = var.additional_sg_ids

  create_node_security_group           = true
  node_security_group_additional_rules = var.node_security_group_additional_rules

  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules

  cluster_endpoint_public_access       = var.cluster.endpoint_public_access || true
  cluster_endpoint_public_access_cidrs = var.endpoint_public_access_cidrs || ["0.0.0.0/0"]

  create_kms_key         = true
  kms_key_administrators = var.auth.kms_key_administrators
  # If you want to maintain the current default behavior of v19.x
  kms_key_enable_default_policy = false

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    key_name        = try(data.aws_key_pair.debug[0].key_name, null)
    create_iam_role = false

    ami_type  = var.ami_type
    disk_size = var.default_disk_size

    tags = var.tags
  }
  eks_managed_node_groups = local.node_group

  # Fargate profiles
  fargate_profiles = merge(
    {
      for k, v in try(var.fargate.profiles, merge(
        {
          karpenter = {
            selectors = [
              { namespace = "karpenter" }
            ]
          }
        },
        {
          kube_system = {
            selectors = [
              {
                namespace = "kube-system"
                labels = {
                  k8s-app = "kube-dns"
                }
              }
            ]
          }
        }
        )) : k => {
        selectors = v.selectors
      }
    },
  )

  # Non-blocking warning: resolve_conflicts deprecated attribute
  # Will be Resolved in a future release : https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2635
  cluster_addons = merge(
    { kube-proxy = {
      configuration_values = jsonencode({
        resources = {
          limits = {
            memory = "100M"
          }
          requests = {
            cpu    = "0.015"
            memory = "100M"
          }
        }
      })
    } },
    {
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
    },
    {
      vpc-cni = {
        service_account_role_arn = try(var.vpc_cni.iam_role_arn, module.irsa.vpc_cni_iam_role_arn)
        configuration_values = jsonencode({
          env = {
            # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
            ENABLE_PREFIX_DELEGATION = "true"
            WARM_PREFIX_TARGET       = "1"
          }
        })
      }
    },
  )

  cluster_tags = var.tags
  node_security_group_tags = merge(
    var.node_security_group_tags,
    local.karpenter_tags
  )

  tags = var.tags
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
