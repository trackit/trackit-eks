module "eks" {
  source = "./../"

  aws_region_short = var.aws_region_short

  network = {
    vpc_id                   = local.vpc_id
    subnet_ids               = var.vpc.subnet_ids
    control_plane_subnet_ids = var.vpc.subnet_ids
  }

  cluster = {
    version                = "1.29"
    name                   = var.cluster_name
    endpoint_public_access = false
  }

  kms_key_administrators = [
    "arn:aws:iam::478986666586:user/trackit-eks",
  ]

  ecr_token = {
    password  = data.aws_ecrpublic_authorization_token.token.password
    user_name = data.aws_ecrpublic_authorization_token.token.user_name
  }

  env       = "staging"
  zone_name = "adn.tech"

  tags = var.tags
}
