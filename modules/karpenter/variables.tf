variable "aws_region" {
  description = "AWS Region where the EKS cluster is located"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "ec2_node_class_yaml_body" {
  description = "Optional custom YAML body for EC2 NodeClass"
  type        = string
  default     = ""
}

variable "node_pool_yaml_body" {
  description = "Optional custom YAML body for NodePool"
  type        = string
  default     = ""
}

variable "node_pool_min_instance_memory" {
  description = "Minimum instance memory for NodePool in MiB"
  type        = number
  default     = 2048 # 2 * 1024
}
