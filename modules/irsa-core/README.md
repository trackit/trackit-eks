# EKS IRSA core module

This module is designed to create IAM role for service account (IRSA) and is dedicated to core addons like vpc-cni.

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_vpc_cni_irsa"></a> [vpc\_cni\_irsa](#module\_vpc\_cni\_irsa) | terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks | ~> 5.25 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_region_short"></a> [aws\_region\_short](#input\_aws\_region\_short) | AWS Region short name | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Cluster name | `string` | n/a | yes |
| <a name="input_cluster_oidc_provider_arns"></a> [cluster\_oidc\_provider\_arns](#input\_cluster\_oidc\_provider\_arns) | Cluster OIDC provider ARNs | `list(string)` | n/a | yes |
| <a name="input_create_vpc_cni_irsa"></a> [create\_vpc\_cni\_irsa](#input\_create\_vpc\_cni\_irsa) | Create VPC CNI IRSA | `bool` | `true` | no |
| <a name="input_env"></a> [env](#input\_env) | environment | `string` | `"test"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags | `map(string)` | n/a | yes |
| <a name="input_vpc_cni_enable_ipv4"></a> [vpc\_cni\_enable\_ipv4](#input\_vpc\_cni\_enable\_ipv4) | VPC CNI enable IPv4 | `bool` | `true` | no |
| <a name="input_vpc_cni_enable_ipv6"></a> [vpc\_cni\_enable\_ipv6](#input\_vpc\_cni\_enable\_ipv6) | VPC CNI enable IPv6 | `bool` | `false` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_vpc_cni_iam_role_arn"></a> [vpc\_cni\_iam\_role\_arn](#output\_vpc\_cni\_iam\_role\_arn) | n/a |
| <a name="output_vpc_cni_namespace"></a> [vpc\_cni\_namespace](#output\_vpc\_cni\_namespace) | n/a |
| <a name="output_vpc_cni_service_account_name"></a> [vpc\_cni\_service\_account\_name](#output\_vpc\_cni\_service\_account\_name) | n/a |
<!-- END_TF_DOCS -->
