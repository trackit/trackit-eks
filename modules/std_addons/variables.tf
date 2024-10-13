variable "aws_region" {
  description = "AWS Region short name"
  type        = string
}

variable "env" {
  description = "Environnement where the stack is running"
  type        = string
}

variable "service" {
  description = "Service using this module"
  type        = string
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type = object({
    Environment : string
    service : string
    component : string
  })
}

variable "cluster_name" {
  description = "Name of the Cluster"
  type        = string
}

variable "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  type        = string
}

variable "cluster_version" {
  description = "Kubernetes <major>.<minor> version to use for the EKS cluster (i.e.: 1.22)"
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

variable "create_delay_dependencies" {
  description = "Dependency attribute which must be resolved before starting the `create_delay_duration`"
  type        = list(string)
  default     = []
}

variable "create_kubernetes_resources" {
  description = "Create Kubernetes resource with Helm or Kubernetes provider"
  type        = bool
  default     = true
}

################################################################################
# EBS CSI native addon
################################################################################

variable "enable_ebs_csi" {
  description = "Determines whether to enable EBS CSI EKS native addon"
  type        = bool
  default     = false
}

variable "ebs_csi" {
  description = "EBS CNI native add-on configuration values"
  type        = any
  default     = {}
}

################################################################################
# AWS Load Balancer Controller addon
################################################################################

variable "enable_aws_load_balancer_controller" {
  description = "Enable AWS Load Balancer Controller add-on"
  type        = bool
  default     = false
}

variable "aws_load_balancer_controller" {
  description = "AWS Load Balancer Controller add-on configuration values"
  type        = any
  default     = {}
}

################################################################################
# External DNS
################################################################################

variable "enable_external_dns" {
  description = "Enable external-dns operator add-on"
  type        = bool
  default     = false
}

variable "external_dns" {
  description = "external-dns add-on configuration values"
  type        = any
  default     = {}
}

variable "hosted_zones" {
  description = "hosted zone where records can be managed by external-dns"
  type = list(object({
    name    = string
    arn     = string
    zone_id = optional(string, "")
  }))
  default = []
}

################################################################################
# External Secrets
################################################################################

variable "enable_external_secrets" {
  description = "Enable External Secrets operator add-on"
  type        = bool
  default     = false
}

variable "external_secrets" {
  description = "External Secrets add-on configuration values"
  type        = any
  default     = {}
}

################################################################################
# Vertical Pod Autoscaler
################################################################################

variable "enable_vpa" {
  description = "Enable Vertical Pod Autoscaler add-on"
  type        = bool
  default     = false
}

variable "enable_vpa_updater" {
  description = "Enable Vertical Pod Autoscaler Updater"
  type        = bool
  default     = false
}

variable "vpa" {
  description = "Vertical Pod Autoscaler add-on configuration values"
  type        = any
  default     = {}
}
