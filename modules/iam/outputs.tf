output "cluster_iam_role_arn" {
  description = "Cluster IAM role ARN"
  value       = aws_iam_role.cluster.arn
}

output "node_group_iam_role_arn" {
  description = "Node Group IAM role ARN"
  value       = var.create_node_group_iam_role ? aws_iam_role.node_group[0].arn : null
}

output "kms_key_arn" {
  description = "The Amazon Resource Name (ARN) of the key"
  value       = var.create_encryption_kms_key ? module.kms.key_arn : null
}

output "kms_key_id" {
  description = "The globally unique identifier for the key"
  value       = var.create_encryption_kms_key ? module.kms.key_id : null
}

output "kms_key_policy" {
  description = "The IAM resource policy set on the key"
  value       = var.create_encryption_kms_key ? module.kms.key_policy : null
}
