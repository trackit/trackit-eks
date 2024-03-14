locals {
  role_name_prefix      = "${var.cluster_name}-${var.env}-${var.aws_region_short}"
  cluster_iam_role_name = "eks-${local.role_name_prefix}-cluster"

  cluster_encryption_policy_name = "eks-${local.role_name_prefix}-EKSClusterEncryption"

  node_group_iam_role_name = "eks-${local.role_name_prefix}-node"

  iam_role_policy_prefix = "arn:${data.aws_partition.current.partition}:iam::aws:policy"

  cni_policy = var.cluster_ip_family == "ipv6" ? "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:policy/AmazonEKS_CNI_IPv6_Policy" : "${local.iam_role_policy_prefix}/AmazonEKS_CNI_Policy"
}
