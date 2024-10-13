variable "cluster" {
  description = "EKS cluster configuration"
  type = object({
    version                      = string
    name                         = string
    endpoint_public_access       = bool
    endpoint_public_access_cidrs = list(string)
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

variable "auth" {
  description = "Auth configuration"
  type = object({
    admin_role_arns        = list(string)
    kms_key_administrators = list(string)
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

variable "aws_region" {
  description = "AWS region name"
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

variable "aws_auth_role_arns" {
  description = "AWS auth role ARNs, used for EKS auth config map"
  type        = list(string)
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default = {
    "service" = "eks_terraform"
  }
}

variable "additional_sg_ids" {
  description = "List of additional, externally created security group IDs to attach to the cluster control plane"
  type        = list(string)
  default     = []
}

variable "node_security_group_additional_rules" {
  description = "Additional rules for the node security group"
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    security_groups  = list(string)
    self             = bool
    prefix_list_ids  = list(string)
    ipv6_cidr_blocks = list(string)
  }))
  default = []

}

variable "cluster_security_group_additional_rules" {
  description = "Additional rules for the cluster security group"
  type = list(object({
    description      = string
    from_port        = number
    to_port          = number
    protocol         = string
    cidr_blocks      = list(string)
    security_groups  = list(string)
    self             = bool
    prefix_list_ids  = list(string)
    ipv6_cidr_blocks = list(string)
  }))
  default = []
}

variable "ami_type" {
  description = "node groups AMI type"
  type        = string
  default     = "AL2_x86_64"
}

variable "default_disk_size" {
  description = "Default EBS disk size"
  type        = number
  default     = null
}

variable "fargate" {
  description = "Fargate configuration values"
  type        = any
  default     = {}
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default = {
    "service" = "eks_terraform"
  }
}

variable "node_security_group_tags" {
  description = "Tags for the node security group"
  type        = map(string)
  default     = {}
}

variable "node_groups" {
  description = "Node Groups for the EKS cluster"
  type        = map(any)
  default     = {}
}

variable "node_group_iam_role_arn" {
  description = "Existing IAM role ARN for the Node groups"
  type        = string
  default     = null
}

variable "node_additional_security_group_ids" {
  description = "List of additional security group ids to add to the node security group created"
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "Common tags to apply to all resources"
  type = object({
    Environment : string
    service : string
    component : string
  })
}

variable "service" {
  description = "Service using this module"
  type        = string
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
# Fargate addon
################################################################################

variable "enable_fargate" {
  description = "Determines whether to enable fargate"
  type        = bool
  default     = true
}

variable "fargate" {
  description = "Fargate configuration values"
  type        = any
  default     = {}
}

################################################################################
# External DNS addon
################################################################################

variable "enable_external_dns" {
  description = "Determines whether to enable External DNS addon"
  type        = bool
  default     = true
}

variable "external_dns" {
  description = "external-dns add-on configuration values"
  type        = any
  default     = {}
}

variable "enable_external_dns_sd" {
  description = "Determines whether to enable External DNS addon with AWS Service Discovery"
  type        = bool
  default     = false
}

variable "external_dns_sd" {
  description = "External-dns add-on with AWS Service Discovery configuration values"
  type        = any
  default     = {}
}

################################################################################
# External Secrets addon
################################################################################

variable "enable_external_secrets" {
  description = "Determines whether to enable External Secret addon"
  type        = bool
  default     = true
}

variable "external_secrets" {
  description = "External Secrets add-on configuration values"
  type        = any
  default     = {}
}

################################################################################
# AWS Load Balancer controller addon
################################################################################

variable "enable_aws_load_balancer_controller" {
  description = "Determines whether to enable AWS Load Balancer controller addon"
  type        = bool
  default     = true
}

variable "aws_load_balancer_controller" {
  description = "AWS Load Balancer Controller add-on configuration values"
  type        = any
  default     = {}
}
