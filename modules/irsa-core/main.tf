locals {
  role_name_prefix  = "eks-${var.cluster_name}-${var.env}-${var.aws_region_short}"
  vpc_cni_role_name = "${local.role_name_prefix}-vpc-cni"
  vpc_cni_namespace = "kube-system"
}

module "vpc_cni_irsa" {
  count = var.create_vpc_cni_irsa ? 1 : 0

  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.25"

  role_name = local.vpc_cni_role_name

  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = var.vpc_cni_enable_ipv4
  vpc_cni_enable_ipv6   = var.vpc_cni_enable_ipv6

  oidc_providers = {
    for idx, arn in var.cluster_oidc_provider_arns :
    idx => {
      provider_arn               = arn
      namespace_service_accounts = ["${local.vpc_cni_namespace}:aws-node"] # mandatory
    }
  }

  tags = var.tags
}
