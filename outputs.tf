output "cluster_arn" {
  description = "cluster arn"
  value       = module.eks.cluster_arn
}

output "cluster_ca_certificate" {
  description = "CA cluster certificate"
  value       = module.eks.cluster_certificate_authority_data
}

output "cluster_endpoint" {
  description = "Endpoint for EKS control plane."
  value       = module.eks.cluster_endpoint
}

output "cluster_id" {
  description = "EKS cluster ID (name)"
  value       = module.eks.cluster_name
}

output "cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "cluster_version" {
  description = "EKS cluster version"
  value       = module.eks.cluster_version
}

output "cluster_identity_oidc_issuer_arn" {
  description = "ARN of the OIDC of the cluster"
  value       = module.eks.oidc_provider_arn
}

output "cluster_identity_oidc_issuer_url" {
  description = "URL of the OIDC of the cluster"
  value       = module.eks.cluster_oidc_issuer_url
}

output "oidc" {
  description = "OIDC related outputs"
  value = {
    provider     = module.eks.oidc_provider
    provider_arn = module.eks.oidc_provider_arn
    issuer_url   = module.eks.cluster_oidc_issuer_url
  }
}

output "cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.eks.cluster_security_group_id
}

output "worker_security_group_id" {
  description = "Worker secrity groups ID"
  value       = module.eks.node_security_group_id
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority"
  value       = module.eks.cluster_certificate_authority_data
}

output "aws_auth_configmap_yaml" {
  description = "AWS auth configmap in yaml"
  value       = module.eks.aws_auth_configmap_yaml
}

output "eks_managed_node_groups" {
  description = "Map of EKS managed node group object"
  value       = module.eks.eks_managed_node_groups
}

output "managed_node_groups_iam_role_arns" {
  description = "List of managed node groups IAM role arn"
  value       = [for group in module.eks.eks_managed_node_groups : group.iam_role_arn]
}

output "private_hosted_zone_name" {
  description = "cluster private hosted zone name"
  value       = var.create_private_hosted_zone ? aws_route53_zone.private_zone[0].name : null
}

output "private_hosted_zone_arn" {
  description = "cluster private hosted zone arn"
  value       = var.create_private_hosted_zone ? aws_route53_zone.private_zone[0].arn : null
}

output "private_hosted_zone_id" {
  description = "cluster private hosted zone ID"
  value       = var.create_private_hosted_zone ? aws_route53_zone.private_zone[0].zone_id : null
}
