# ArgoCD module

This module will install ArgoCD helm chart

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.10.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | >= 1.10.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_this"></a> [this](#module\_this) | aws-ia/eks-blueprints-addon/aws | 1.0.0 |

## Resources

| Name | Type |
|------|------|
| [kubectl_manifest.applicationset_bootstrap](https://registry.terraform.io/providers/gavinbunney/kubectl/latest/docs/resources/manifest) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_argocd"></a> [argocd](#input\_argocd) | ArgoCD related values | `any` | n/a | yes |
| <a name="input_argocd_ingress_scheme"></a> [argocd\_ingress\_scheme](#input\_argocd\_ingress\_scheme) | ArgoCD ingress scheme | `string` | `"internal"` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | AWS region | `string` | n/a | yes |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | EKS cluster name | `string` | n/a | yes |
| <a name="input_env"></a> [env](#input\_env) | environment | `string` | n/a | yes |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
