module "iam" {
  source = "./modules/iam"

  cluster_name               = var.cluster.name
  cluster_oidc_provider_arns = module.eks.oidc_provider_arns

  tags = var.tags
}
