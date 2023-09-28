variable "encryption_kms_key_arn" {
  description = "Enable the encryption of secrets using KMS by giving the KMS ARN"
  default     = ""
  type        = string
}

variable "cluster_name" {
  description = "Name of the Cluster"
  type        = string
}

variable "cluster_tags" {
  description = "A map of additional tags to add to the cluster"
  type        = map(string)
  default     = {}
}

variable "default_disk_size" {
  description = "Default EBS disk size"
  type        = number
  default     = null
}

variable "env" {
  description = "Environnement where the stack is running"
  type        = string
}

variable "node_groups" {
  description = "Node Groups for the EKS cluster"
  type        = map(any)
  default     = {}
}

variable "ami_type" {
  description = "node groups AMI type"
  type        = string
  default     = "AL2_x86_64"
}

variable "private_subnets" {
  description = "Private Subnets"
  type        = list(string)
}

variable "aws_region_short" {
  description = "AWS Region short name"
  type        = string
}

variable "service" {
  description = "Service using this module"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "k8s_endpoint_public_access" {
  description = "Enable Public access to Kubernetes API endpoint"
  type        = bool
  default     = false
}

variable "k8s_endpoint_public_access_cidrs" {
  description = "CIDRs from which it is possible to access the cluster using the public endpoint (must be public IPs)"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "k8s_endpoint_private_access_cidrs" {
  description = "CIDRs from which it is possible to access the cluster using the private endpoint"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "key_pair_name" {
  description = "SSH key pair name"
  type        = string
  default     = null
}

variable "node_security_group_additional_rules" {
  description = "List of additional security group rules to add to the node security group created. Set `source_cluster_security_group = true` inside rules to set the `cluster_security_group` as source"
  type        = any
  default     = {}
}

variable "cluster_security_group_additional_rules" {
  description = "List of additional security group rules to add to the cluster security group created. Set `source_node_security_group = true` inside rules to set the `node_security_group` as source"
  type        = any
  default     = {}
}

variable "node_additional_security_group_ids" {
  description = "List of additional security group ids to add to the node security group created"
  type        = list(string)
  default     = []
}

variable "cluster_version" {
  description = "Kubernetes <major>.<minor> version to use for the EKS cluster (i.e.: 1.22)"
  type        = string
  default     = null
}

variable "cluster_additional_security_group_ids" {
  description = "List of additional, externally created security group IDs to attach to the cluster control plane"
  type        = list(string)
  default     = []
}

variable "create_private_hosted_zone" {
  description = "create the private hosted zone dedicated to the cluster"
  type        = bool
  default     = true
}

variable "private_hosted_zone_additional_vpc_ids_association" {
  description = "additional VPC IDs to be associated to, in the format [\"vpc_id,aws_region\"]"
  type        = list(string)
  default     = []
}
variable "cluster_iam_role_arn" {
  description = "Existing IAM role ARN for the cluster"
  type        = string
  default     = null
}

variable "node_group_iam_role_arn" {
  description = "Existing IAM role ARN for the Node groups"
  type        = string
  default     = null
}

variable "zone_name" {
  description = "Route53 zone name, used for private hosted zone"
  type       = string
}
