locals {
  alb_controller_service_account_name = "aws-load-balancer-controller-sa"
  alb_controller_namespace            = "kube-system"

  external_dns_service_account_name = "external-dns-sa"
  external_dns_namespace            = "external-dns"

  cert_manager_service_account_name = "cert-manager-sa"
  cert_manager_namespace            = "cert-manager"

  external_secrets_service_account_name = "external-secrets-sa"
  external_secrets_namespace            = "external-secrets"

  private_subnet = [
    "subnet-053ec5a7557a62dd0",
    "subnet-03c80c595a93c7b36",
    "subnet-0322b7da3cdebca2b"
  ]
  vpc_id = "vpc-03f093146177151fd"
}
