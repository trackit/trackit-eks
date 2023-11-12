# EKS AWS Auth module

This module is used to manage aws-auth configMap.

The code is extracted from official EKS module : https://github.com/terraform-aws-modules/terraform-aws-eks/blob/master/main.tf#L465

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 2.0.2 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | >= 2.20.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_kubectl"></a> [kubectl](#provider\_kubectl) | >= 2.0.2 |
| <a name="provider_kubernetes"></a> [kubernetes](#provider\_kubernetes) | >= 2.20.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [kubectl_manifest.readonly_clusterrolebinding](https://registry.terraform.io/providers/alekc/kubectl/latest/docs/resources/manifest) | resource |
| [kubernetes_config_map_v1_data.aws_auth](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/resources/config_map_v1_data) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_role_arns"></a> [admin\_role\_arns](#input\_admin\_role\_arns) | List of ARN roles that are admin on the cluster | `list(string)` | `[]` | no |
| <a name="input_aws_auth_accounts"></a> [aws\_auth\_accounts](#input\_aws\_auth\_accounts) | Additional AWS account numbers to add to the aws-auth configmap. | `list(string)` | `[]` | no |
| <a name="input_aws_auth_roles"></a> [aws\_auth\_roles](#input\_aws\_auth\_roles) | Additional IAM roles to add to the aws-auth configmap. | <pre>list(object({<br>    rolearn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_aws_auth_users"></a> [aws\_auth\_users](#input\_aws\_auth\_users) | Additional IAM users to add to the aws-auth configmap. | <pre>list(object({<br>    userarn  = string<br>    username = string<br>    groups   = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_fargate_profile_pod_execution_role_arns"></a> [fargate\_profile\_pod\_execution\_role\_arns](#input\_fargate\_profile\_pod\_execution\_role\_arns) | Amazon Resource Name (ARN) of the EKS Fargate Profile Pod execution role ARN | `list` | `[]` | no |
| <a name="input_node_iam_role_arns"></a> [node\_iam\_role\_arns](#input\_node\_iam\_role\_arns) | List of node IAM role arns to add to the aws-auth configmap | `list` | `[]` | no |
| <a name="input_read_only_role_arns"></a> [read\_only\_role\_arns](#input\_read\_only\_role\_arns) | List of ARN roles that are RO on the cluster | `list(string)` | `[]` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->
