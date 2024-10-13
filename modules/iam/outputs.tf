output "vpc_cni_iam_role_arn" {
  description = "ARN of IAM role for VPC CNI"
  value       = module.vpc_cni_irsa[0].iam_role_arn
}

output "vpc_cni_service_account_name" {
  description = "Account name of IAM role for VPC CNI"
  value       = "${local.role_name}-vpc-cni"
}

output "iam_namespace" {
  description = "Namespace for VPC CNI"
  value       = "kube-system"
}

output "ebs_csi_iam_role_arn" {
  description = "ARN of IAM role for EBS CSI"
  value       = module.ebs_csi_irsa[0].iam_role_arn
}

output "ebs_csi_service_account_name" {
  description = "Account name of IAM role for EBS CSI"
  value       = "ebs-csi-controller-sa"
}
