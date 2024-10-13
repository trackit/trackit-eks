variable "argocd" {
  description = "ArgoCD related values"
  type = object({
    name                       = string
    namespace                  = string
    chart_version              = string
    hostname                   = string
    gitlab_app_id              = string
    gitlab_app_installation_id = string
    gitlab_app_private_key     = string
    rbac_policy_default        = string
    rbac_policy_csv            = string
    bootstrap_url              = string
    bootstrap_path             = string
  })
}

variable "cluster" {
  description = "EKS cluster configuration"
  type = object({
    name              = string
    endpoint          = string
    version           = string
    oidc_provider_arn = string
  })
}

variable "env" {
  type        = string
  description = "environment"
}

variable "aws_region" {
  type        = string
  description = "AWS region"
}

variable "argocd_ingress_scheme" {
  description = "ArgoCD ingress scheme"
  type        = string
  default     = "internal"
}
