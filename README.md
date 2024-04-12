# AWS EKS Cluster Terraform Module Documentation

## Overview

This Terraform module is designed to deploy and configure an AWS EKS cluster. It includes the setup of IAM roles, creation of the EKS cluster, and configuration of additional dependencies such as Fargate profiles, Karpenter for auto-scaling, and IAM Roles for Service Accounts (IRSA) for the AWS ALB Ingress Controller and ExternalDNS.

## Prerequisites

- AWS CLI installed and configured
- Terraform v0.12+ installed
- Appropriate AWS permissions to create and manage EKS, IAM, and related resources

## Usage

To use this module, include it in your Terraform configuration with the required variables and settings. Below is an example of how to use this module to create an EKS cluster:

```terraform
module "eks" {
  source = "./../"  # Adjust the source path based on your Terraform files structure

  aws_region_short = "us-west-2"  # Specify the AWS region

  network = {
    vpc_id                   = "vpc-0a1b2c3d4e"
    subnet_ids               = ["subnet-67890", "subnet-abcde"]
    control_plane_subnet_ids = ["subnet-67890", "subnet-abcde"]
  }

  cluster = {
    version                = "1.29"
    name                   = "my-eks-cluster"
    endpoint_public_access = false
  }

  kms_key_administrators = [
    "arn:aws:iam::123456789012:user/my-user",
  ]

  ecr_token = {
    password  = "examplepassword"
    user_name = "exampleusername"
  }

  env       = "staging"
  zone_name = "example.com"

  tags = {
    Environment = "staging"
    Team        = "devops"
  }
}
```

## Variables

- **aws_region_short** - The short name of the AWS region where the resources will be created.
- **network** - Configuration for the VPC and subnets.
- **cluster** - Specifications of the EKS cluster including version, name, and access settings.
- **kms_key_administrators** - AWS KMS key administrators for encrypted resources.
- **ecr_token** - Token for ECR authentication.
- **env** - Deployment environment identifier.
- **zone_name** - DNS zone name for route53 configurations.
- **tags** - Tags to apply to all resources created.

## Outputs

- **cluster_arn** - The ARN of the EKS cluster.
- **cluster_endpoint** - The endpoint URL for the Kubernetes API server.
- **cluster_oidc_issuer_url** - The URL for the OIDC provider.
- **node_security_group_id** - Security group ID associated with the node groups.
- **karpenter_iam_role_arn** - IAM role ARN used by Karpenter.

## Modules

This configuration uses several modules:

- **module.iam** - Manages IAM roles and policies.
- **module.eks** - Main module for creating and managing the EKS cluster.
- **module.karpenter** - Manages Karpenter-specific configurations for auto-scaling.
- **module.eks_auth** - Manages Kubernetes auth configurations.

## Contributing

To contribute to this project, please create pull requests or issues in the project's GitHub repository. Ensure you follow the existing code styles and add tests for new features.
