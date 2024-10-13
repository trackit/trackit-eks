output "eks_addons" {
  description = "Map of attributes for each EKS addons enabled"
  value       = try(module.eks_blueprints_addons[0].eks_addons, null)
}

output "aws_load_balancer_controller" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.eks_blueprints_addons[0].aws_load_balancer_controller, null)
}

output "external_dns" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.eks_blueprints_addons[0].external_dns, null)
}

output "external_secrets" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.eks_blueprints_addons[0].external_secrets, null)
}

output "vpa" {
  description = "Map of attributes of the Helm release and IRSA created"
  value       = try(module.eks_blueprints_addons[0].vpa, null)
}

output "aws_load_balancer_controller_delay_dependency" {
  description = "Custom dependency to use for resources that must wait"
  value       = try(time_sleep.this[0].triggers.aws_load_balancer_controller, null)
}

output "external_dns_delay_dependency" {
  description = "Custom dependency to use for resources that must wait"
  value       = try(time_sleep.this[0].triggers.external_dns, null)
}

output "vpa_delay_dependency" {
  description = "Custom dependency to use for resources that must wait"
  value       = try(time_sleep.this[0].triggers.vpa, null)
}
