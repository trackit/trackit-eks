output "vpc_cni_iam_role_arn" {
  value = var.create_vpc_cni_irsa ? module.vpc_cni_irsa[0].iam_role_arn : null
}

output "vpc_cni_service_account_name" {
  value = local.vpc_cni_role_name
}

output "vpc_cni_namespace" {
  value = local.vpc_cni_namespace
}
