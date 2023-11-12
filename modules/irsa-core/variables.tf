variable "aws_region_short" {
  description = "AWS Region short name"
  type        = string
}

variable "env" {
  description = "environment"
  type        = string
  default     = "test"
}

variable "tags" {
  description = "Tags"
  type        = map(string)
}

variable "cluster_name" {
  description = "Cluster name"
  type        = string
}

variable "cluster_oidc_provider_arns" {
  description = "Cluster OIDC provider ARNs"
  type        = list(string)
}

variable "create_vpc_cni_irsa" {
  description = "Create VPC CNI IRSA"
  type        = bool
  default     = true
}

variable "vpc_cni_enable_ipv4" {
  description = "VPC CNI enable IPv4"
  type        = bool
  default     = true
}

variable "vpc_cni_enable_ipv6" {
  description = "VPC CNI enable IPv6"
  type        = bool
  default     = false
}
