module "auth" {
  source = "./modules/auth"

  manage_aws_auth_configmap = var.auth.manage_aws_auth_configmap
  aws_auth_accounts         = var.auth.aws_auth_accounts
  aws_auth_users            = var.auth.aws_auth_users
  aws_auth_roles            = var.auth.aws_auth_roles
}
