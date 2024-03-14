variable "cluster_name" {
  description = "Name of the Cluster"
  type        = string
}

variable "create_cloudwatch_log_group" {
  description = "create cloudwatch log group"
  type        = bool
  default     = false
}

variable "cluster_ip_family" {
  description = "cluster IP family"
  type        = string
  default     = "ipv4"
}

variable "cluster_iam_role_additional_policies" {
  description = "cluster IAM role additional policies to attach"
  type        = map(string)
  default     = {}
}

variable "create_node_group_iam_role" {
  description = "Determines if an IAM role is created for the cluster node group"
  type        = bool
  default     = true
}

variable "node_group_iam_role_additional_policies" {
  description = "node group IAM role additional policies to attach"
  type        = map(string)
  default     = {}
}

variable "create_encryption_kms_key" {
  description = "create encryption kms key"
  type        = bool
  default     = true
}

variable "tags" {
  description = "tags"
  type        = map(string)
  default     = {}
}

variable "env" {
  description = "environment"
  type        = string
  default     = "test"
}

variable "service" {
  description = "service name (team)"
  type        = string
  default     = ""
}

variable "aws_region_short" {
  description = "service name (team)"
  type        = string
}

variable "kms_key_administrators" {
  description = "kms key administrators list"
  type        = list(string)
  default     = []
}
