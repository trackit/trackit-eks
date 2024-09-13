module "eks" {
  source = "./../"

  aws_region_short = var.aws_region_short

  network = {
    vpc_id                   = local.vpc_id
    subnet_ids               = var.vpc.subnet_ids
    control_plane_subnet_ids = var.vpc.subnet_ids
  }

  cluster = {
    version                = "1.29"
    name                   = var.cluster_name
    endpoint_public_access = false
  }

  kms_key_administrators = [
    "arn:aws:iam::XXXXXXXX:user/trackit-eks",
  ]

  ecr_token = {
    password  = data.aws_ecrpublic_authorization_token.token.password
    user_name = data.aws_ecrpublic_authorization_token.token.user_name
  }

  env       = "staging"
  zone_name = "XXXX.tech"

  tags = var.tags
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
}
