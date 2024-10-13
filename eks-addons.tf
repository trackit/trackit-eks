module "std_addons" {
  source = "./modules/std_addons"

  env        = var.env
  aws_region = var.aws_region
  service    = var.service
  tags       = var.tags

  cluster_endpoint  = module.eks.cluster_endpoint
  cluster_version   = module.eks.cluster_version
  oidc_provider_arn = module.eks.oidc_provider_arn

  cluster_name = module.eks.cluster_name

  enable_ebs_csi = var.enable_ebs_csi
  ebs_csi = merge(
    {
      iam_role_arn = module.irsa.ebs_csi_iam_role_arn
    }, var.ebs_csi,
  )

  # We want to wait for Karpenter and coredns to be deployed first
  create_delay_dependencies = compact(concat(
    [module.karpenter.delay_dependency],
    try([module.eks.cluster_addons["coredns"]["name"]], []),
    [module.observability.prometheus_crds_dependency],
  ))

  enable_external_dns = var.enable_external_dns
  external_dns = merge(
    var.external_dns,
    # Avoid DNS record creation for nginx-ingress as it does not expose external IP address
    can(var.ingress_nginx_alb.target_group_arn) ? {
      extra_args = concat(["--ingress-class=alb"], try(var.external_dns.extra_args, []))
    } : {}
  )
  hosted_zones = concat(
    module.private_zone.zone,
    [for v in data.aws_route53_zone.argocd : { name = v.name, zone_id = v.zone_id, arn = v.arn }],
    [for v in data.aws_route53_zone.additional : { name = v.name, zone_id = v.zone_id, arn = v.arn }],
  )

  enable_external_secrets = var.enable_external_secrets
  external_secrets        = var.external_secrets

  enable_aws_load_balancer_controller = var.enable_aws_load_balancer_controller
  aws_load_balancer_controller        = var.aws_load_balancer_controller
}
