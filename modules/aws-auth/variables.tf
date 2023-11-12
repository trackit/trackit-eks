variable "node_iam_role_arns" {
  description = "List of node IAM role arns to add to the aws-auth configmap"
  default     = []
}

variable "aws_auth_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap."
  type = list(object({
    rolearn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "fargate_profile_pod_execution_role_arns" {
  description = "Amazon Resource Name (ARN) of the EKS Fargate Profile Pod execution role ARN"
  default     = []
}

variable "aws_auth_users" {
  description = "Additional IAM users to add to the aws-auth configmap."
  type = list(object({
    userarn  = string
    username = string
    groups   = list(string)
  }))
  default = []
}

variable "aws_auth_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap."
  type        = list(string)
  default     = []
}

variable "admin_role_arns" {
  description = "List of ARN roles that are admin on the cluster"
  type        = list(string)
  default     = []
}

variable "read_only_role_arns" {
  description = "List of ARN roles that are RO on the cluster"
  type        = list(string)
  default     = []
}
