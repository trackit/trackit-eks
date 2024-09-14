locals {
  role_name = "eks-${var.cluster_name}"
}

module "vpc_cni_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39.1"

  role_name = "${local.role_name}-vpc-cni"

  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true
  vpc_cni_enable_ipv6   = false

  oidc_providers = {
    for idx, arn in var.cluster_oidc_provider_arns :
    idx => {
      provider_arn               = arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }

  tags = var.tags
}

module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39.1"

  role_name = "${local.role_name}-ebs-csi"

  attach_ebs_csi_policy = true

  oidc_providers = {
    for idx, arn in var.cluster_oidc_provider_arns :
    idx => {
      provider_arn = arn
      namespace_service_accounts = [
        "kube-system:ebs-csi-controller-sa"
      ]
    }
  }

  tags = var.tags
}
