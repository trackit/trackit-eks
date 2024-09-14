variable "tags" {
  description = "Tags"
  type        = map(string)
  default = {
    "service" = "eks_terraform"
  }
}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "cluster_oidc_provider_arns" {
  description = "OIDC provider ARNs"
  type        = list(string)
}
