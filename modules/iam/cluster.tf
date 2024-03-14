################################################################################
# IAM Role
################################################################################

resource "aws_iam_role" "cluster" {
  name        = local.cluster_iam_role_name
  description = "EKS Cluster IAM role"

  assume_role_policy    = data.aws_iam_policy_document.cluster_assume_role_policy.json
  force_detach_policies = true

  # https://github.com/terraform-aws-modules/terraform-aws-eks/issues/920
  # Resources running on the cluster are still generating logs when destroying the module resources
  # which results in the log group being re-created even after Terraform destroys it. Removing the
  # ability for the cluster role to create the log group prevents cluster log group from being re-created
  # outside of Terraform due to services still generating logs during destroy process
  dynamic "inline_policy" {
    for_each = var.create_cloudwatch_log_group ? [1] : []
    content {
      name = local.cluster_iam_role_name

      policy = jsonencode({
        Version = "2012-10-17"
        Statement = [
          {
            Action   = ["logs:CreateLogGroup"]
            Effect   = "Deny"
            Resource = "*"
          },
        ]
      })
    }
  }

  tags = var.tags
}

# Policies attached ref https://docs.aws.amazon.com/eks/latest/userguide/service_IAM_role.html
resource "aws_iam_role_policy_attachment" "cluster" {
  for_each = { for k, v in {
    AmazonEKSClusterPolicy         = "${local.iam_role_policy_prefix}/AmazonEKSClusterPolicy",
    AmazonEKSVPCResourceController = "${local.iam_role_policy_prefix}/AmazonEKSVPCResourceController",
  } : k => v }

  policy_arn = each.value
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_additional" {
  for_each = { for k, v in var.cluster_iam_role_additional_policies : k => v }

  policy_arn = each.value
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_encryption" {
  # Encryption config not available on Outposts
  count = var.create_encryption_kms_key ? 1 : 0

  policy_arn = aws_iam_policy.cluster_encryption[0].arn
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_policy" "cluster_encryption" {
  # Encryption config not available on Outposts
  count = var.create_encryption_kms_key ? 1 : 0

  name        = local.cluster_encryption_policy_name
  description = "EKS cluster encryption policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ListGrants",
          "kms:DescribeKey",
        ]
        Effect   = "Allow"
        Resource = module.kms.key_arn
      },
    ]
  })

  tags = var.tags
}
