variable "vpc" {
  description = "The VPC custom configuration"
  type = object({
    id                 = string
    name               = string
    cidr               = string
    azs                = list(string)
    private_subnets    = list(string)
    public_subnets     = list(string)
    enable_nat_gateway = bool
    create_igw         = bool
    subnet_ids         = list(string)
  })
}

variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "eu-west-1"
}

variable "aws_region_short" {
  description = "AWS Region short"
  type        = string
  default     = "euw1"
}

variable "tags" {
  description = "Tags"
  type        = map(string)
  default = {
    env     = "staging"
    service = "trackit"
  }
}

variable "cluster_name" {
  description = "Name of the Cluster"
  type        = string
  default     = "trackit-eks-dev"
}

variable "public_subnet_tags" {
  description = "Additional tags for the public subnets"
  type        = map(string)
  default     = {}
}

variable "private_subnet_tags" {
  description = "Additional tags for the private subnets"
  type        = map(string)
  default     = {}
}
