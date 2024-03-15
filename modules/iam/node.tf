################################################################################
# IAM Role
################################################################################

resource "aws_iam_role" "node_group" {
  count       = var.create_node_group_iam_role ? 1 : 0
  name        = local.node_group_iam_role_name
  description = "EKS Node Group IAM role"

  assume_role_policy    = data.aws_iam_policy_document.node_group_assume_role_policy.json
  force_detach_policies = true

  tags = var.tags
}

# Policies attached ref https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_node_group
resource "aws_iam_role_policy_attachment" "node_group" {
  for_each = { for k, v in toset(compact([
    "${local.iam_role_policy_prefix}/AmazonEKSWorkerNodePolicy",
    "${local.iam_role_policy_prefix}/AmazonEC2ContainerRegistryReadOnly",
    local.cni_policy,
  ])) : k => v if var.create_node_group_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.node_group[0].name
}

resource "aws_iam_role_policy_attachment" "node_group_additional" {
  for_each = { for k, v in var.node_group_iam_role_additional_policies : k => v if var.create_node_group_iam_role }

  policy_arn = each.value
  role       = aws_iam_role.node_group[0].name
}
