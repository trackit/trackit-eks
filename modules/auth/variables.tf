variable "manage_aws_auth_configmap" {
  description = "Whether to manage the aws-auth configmap"
  type        = bool
  default     = true
}

variable "aws_auth_accounts" {
  description = "Additional AWS account numbers to add to the aws-auth configmap"
  type        = list(string)
  default     = []
}

variable "aws_auth_users" {
  description = "Additional IAM users to add to the aws-auth configmap"
  type = object({
    userarn  = string
    username = string
    groups   = list(string)
  })
  default = []
}

variable "aws_auth_roles" {
  description = "Additional IAM roles to add to the aws-auth configmap"
  type = object({
    rolearn  = string
    username = string
    groups   = list(string)
  })
  default = []
}
