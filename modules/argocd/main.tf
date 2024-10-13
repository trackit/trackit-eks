resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }

  depends_on = [module.eks]
}

module "eks-blueprints-addons-argocd" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0"

  cluster_name      = var.cluster.name
  cluster_endpoint  = var.cluster.endpoint
  cluster_version   = var.cluster.version
  oidc_provider_arn = var.cluster.oidc_provider_arn

  enable_argocd = true

  argocd = {
    name          = "argocd"
    chart_version = "5.42.2"
    repository    = "https://argoproj.github.io/argo-helm"
    namespace     = "argocd"
    values = [
      <<YAML
      dex:
        enabled: false
      server:
        ingress:
          enabled: true
          hosts:
            - ${try(var.argocd.hostname, null)}
          ingressClassName: alb
          extraArgs:
            - --insecure
          annotations:
            kubernetes.io/ingress.class: alb
            alb.ingress.kubernetes.io/scheme: ${var.argocd_ingress_scheme}
            alb.ingress.kubernetes.io/healthcheck-path: /health
            alb.ingress.kubernetes.io/group.name: default
            alb.ingress.kubernetes.io/target-type: ip
            alb.ingress.kubernetes.io/ssl-redirect: '443'
            alb.ingress.kubernetes.io/backend-protocol: HTTPS
            alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
            alb.ingress.kubernetes.io/listen-ports: '[{"HTTP": 80, "HTTPS":443}]'
            external-dns.alpha.kubernetes.io/hostname: ${try(var.argocd.hostname, null)}
            alb.ingress.kubernetes.io/certificate-arn: arn:aws:acm:eu-west-3:478986666586:certificate/3523d616-a021-4c11-bae8-4cc9805984e7
            alb.ingress.kubernetes.io/subnets: subnet-0c05df4ce01c37f7c,subnet-085d4eaf7d78467c8,subnet-0b871eff9a4914e47
        configs:
          secret:
            argocdServerAdminPassword: azertyuiop0987654321%
            gitlabAppId: ${var.argocd.gitlab_app_id}
            gitlabAppInstallationId: ${var.argocd.gitlab_app_installation_id}
            gitlabAppPrivateKey: ${var.argocd.gitlab_app_private_key}
        rbacConfig:
          policy.default: ${var.argocd.rbac_policy_default}
          policy.csv: ${var.argocd.rbac_policy_csv}
        repository.credentials: |
          - url: https://gitlab.com/VizMediaEurope/adn-eks-apps
            passwordSecret:
              name: gitlab
              key: password
            usernameSecret:
              name: gitlab
              key: username
        bootstrap:
          url: ${var.argocd.bootstrap_url}
          path: ${var.argocd.bootstrap_path}
      YAML
    ]
  }

  depends_on = [kubernetes_namespace.argocd]
}
