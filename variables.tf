variable "cluster" {
  description = "EKS cluster configuration"
  type = object({
    version                = string
    name                   = string
    endpoint_public_access = bool
  })
}

variable "network" {
  description = "Network configuration"
  type = object({
    vpc_id                   = string
    subnet_ids               = list(string)
    control_plane_subnet_ids = list(string)
  })
}

variable "ecr_token" {
  description = "ECR token"
  type = object({
    user_name = string
    password  = string
  })
}

variable "fargate_profiles" {
  description = "Fargate profiles"
  type        = any
  default     = {}
}

variable "tags" {
  description = "Tags"
  type        = map(string)
}

variable "aws_region_short" {
  description = "AWS region short name"
  type        = string
}

variable "kms_key_administrators" {
  description = "KMS key administrators"
  type        = list(string)
}

variable "zone_name" {
  description = "Zone name"
  type        = string
}

variable "env" {
  description = "value of the environment"
  type        = string
}

variable "private_hosted_zone_additional_vpc_ids_association" {
  description = "Private hosted zone additional VPC IDs association"
  type        = list(string)
  default     = []
}
