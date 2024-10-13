module "argocd" {
  source = "./modules/argocd"

  env        = "staging"
  aws_region = var.aws_region

  cluster = {
    name              = module.eks.cluster_name
    endpoint          = module.eks.cluster_endpoint
    version           = module.eks.cluster_version
    oidc_provider_arn = module.eks.oidc.provider_arn
  }

  argocd = {
    name          = "argocd"
    namespace     = "argocd"
    chart_version = "5.29.1"

    hostname = "argocd-${module.eks.cluster_name}-cluster-${var.tags.env}.stg.anidn.fr"

    gitlab_app_id              = "id"
    gitlab_app_installation_id = "id"
    gitlab_app_private_key     = "key"

    rbac_policy_default = "role:readonly"
    rbac_policy_csv     = <<-EOF
g, innov-ft:infra, role:admin
EOF

    bootstrap_url  = "https://gitlab.com/VizMediaEurope/adn-eks-apps.git"
    bootstrap_path = "staging/services/*"
  }

  argocd_ingress_scheme = "internet-facing"

  depends_on = [
    module.std_addons,
  ]
}
