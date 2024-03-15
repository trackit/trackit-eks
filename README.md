# Documentation

To deploy and configure an AWS EKS cluster using Terraform, this guide will walk you through the usage of a custom Terraform module alongside explanations of key tools and AWS add-ons involved in the process. The deployment consists of three main steps: setting up IAM roles for EKS, creating the EKS cluster itself, and adding extra dependencies like Fargate profiles, Karpenter for auto-scaling, and IAM Roles for Service Accounts (IRSA) for AWS ALB Ingress Controller and ExternalDNS.

## Example

```terraform
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
```
