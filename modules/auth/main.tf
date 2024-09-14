module "aws_auth" {
  source  = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version = "~> 20.20.0"

  manage_aws_auth_configmap = var.manage_aws_auth_configmap
  aws_auth_accounts         = var.aws_auth_accounts
  aws_auth_users            = var.aws_auth_users
  aws_auth_roles = concat(
    # Extra auth roles
    module.aws_auth_extra.aws_auth_roles,
    # Custom Auth roles
    var.aws_auth_roles,
  )
}
