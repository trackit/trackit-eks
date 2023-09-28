module "eks" {
  source = "terraform-aws-modules/eks/aws"
  # Keep this version same as EKS Karpenter and EKS Fargate profile dependencies module version
  version = "19.15.3"

  node_security_group_use_name_prefix    = true
  cluster_security_group_use_name_prefix = true

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version

  vpc_id     = var.vpc_id
  subnet_ids = var.private_subnets

  enable_irsa                     = true
  cluster_endpoint_private_access = true

  create_iam_role = false
  iam_role_arn    = var.cluster_iam_role_arn

  # disable aws-auth configmap
  manage_aws_auth_configmap = false

  create_cluster_security_group         = length(var.k8s_endpoint_private_access_cidrs) > 0
  cluster_additional_security_group_ids = var.cluster_additional_security_group_ids

  node_security_group_additional_rules = var.node_security_group_additional_rules

  cluster_security_group_additional_rules = var.cluster_security_group_additional_rules

  cluster_endpoint_public_access       = var.k8s_endpoint_public_access
  cluster_endpoint_public_access_cidrs = var.k8s_endpoint_public_access_cidrs

  create_kms_key = false
  cluster_encryption_config = {
    provider_key_arn = var.encryption_kms_key_arn
    resources        = ["secrets"]
  }

  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    key_name        = try(data.aws_key_pair.debug[0].key_name, null)
    create_iam_role = false

    ami_type  = var.ami_type
    disk_size = var.default_disk_size

    tags = {
      Environment = var.env
      Creator     = "Terraform"
      service     = var.service
    }

    additional_tags = {
      Name        = "${var.cluster_name}-eks-node"
      Environment = var.env
      Creator     = "${var.cluster_name} EKS Node Group"
      service     = var.service
    }
  }
  eks_managed_node_groups = local.node_group

  cluster_tags = var.cluster_tags

  tags = {
    Environment = var.env
    Creator     = "Terraform"
    Name        = var.cluster_name
    service     = var.service
  }
}
