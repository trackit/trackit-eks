################################################################################
# KMS Key
################################################################################

module "kms" {
  source  = "terraform-aws-modules/kms/aws"
  version = "1.1.0" # Note - be mindful of Terraform/provider version compatibility between modules

  create                  = var.create_encryption_kms_key
  description             = "${var.cluster_name} cluster encryption key used to encrypt resources, mainly k8s secrets"
  key_usage               = "ENCRYPT_DECRYPT"
  deletion_window_in_days = 30
  enable_key_rotation     = false

  # Policy
  enable_default_policy = false
  key_owners            = []
  key_administrators = distinct(compact(concat(
    [data.aws_iam_session_context.current.issuer_arn], # terraform role codeowner
    var.kms_key_administrators,
    ["arn:aws:iam::478986666586:role/TrackitMonitoringAdmin"],
  )))
  key_users                 = [aws_iam_role.cluster.arn]
  key_service_users         = []
  source_policy_documents   = []
  override_policy_documents = []

  # Aliases
  aliases = []
  computed_aliases = {
    # Computed since users can pass in computed values for cluster name such as random provider resources
    cluster = {
      name = "service/${var.service}/eks/${var.env}/${var.cluster_name}"
    }
  }

  tags = merge(
    {
      component   = "kms-eks-${var.cluster_name}"
      service     = var.service
      Name        = var.cluster_name
      Environment = var.env
      Creator     = "Terraform"
    },
    var.tags
  )
}
