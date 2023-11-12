variable "env" {
  description = "Environnement where the stack is running"
  type        = string
}

variable "service" {
  description = "Service using this module"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes `<major>.<minor>` version to use for the EKS cluster (i.e.: `1.24`)"
  type        = string
}

variable "oidc_provider_arn" {
  description = "The ARN of the cluster OIDC Provider"
  type        = string
}

variable "create" {
  description = "Controls if resources should be created (affects all resources)"
  type        = bool
  default     = true
}

variable "karpenter" {
  description = "Karpenter add-on configuration values"
  type        = any
  default     = {}
}

variable "create_aws_node_template" {
  type        = bool
  default     = true
}

variable "subnet_ids" {
  type        = list(string)
}

variable "aws_node_template" {
  type        = any
  default     = {}
}

variable "create_provisioner" {
  type        = bool
  default     = true
}

variable "availability_zones" {
  type        = list(string)
}

variable "provisioner" {
  description = "Provisioner configuration values"
  type        = any
  default     = {}
}

variable "create_delay_dependencies" {
  type        = list(string)
  default     = []
}

variable "create_kubernetes_resources" {
  type        = bool
  default     = true
}
