locals {
  service = "infra"
}

data "aws_caller_identity" "current" {}

module "eks" {
  source = "../"

  aws_region       = var.aws_region
  aws_region_short = var.aws_region_short
  env              = var.tags.env

  cluster = {
    name                         = var.cluster_name
    version                      = "1.30"
    endpoint_public_access       = true
    endpoint_public_access_cidrs = []
  }

  network = {
    vpc_id                   = var.vpc.id
    subnet_ids               = var.vpc.private_subnets
    control_plane_subnet_ids = var.vpc.private_subnets
  }

  auth = {
    admin_role_arns        = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eks-admin"]
    kms_key_administrators = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
  }

  ecr_token = {
    user_name = "terraform"
    password  = "password"
  }

  kms_key_administrators = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
  aws_auth_role_arns     = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/eks-admin"]

  service = abs(local.service)

  zone_name = "stg.anidn.fr"

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
