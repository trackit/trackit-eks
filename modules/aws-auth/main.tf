locals {
  node_iam_role_arns = var.node_iam_role_arns

  aws_auth_configmap_data = {
    mapRoles = yamlencode(concat(
      [for arn in local.node_iam_role_arns : {
        rolearn  = arn
        username = "system:node:{{EC2PrivateDNSName}}"
        groups = [
          "system:bootstrappers",
          "system:nodes",
        ]
        }
      ],
      [
        for role_arn in var.fargate_profile_pod_execution_role_arns : {
          rolearn  = role_arn
          username = "system:node:{{SessionName}}"
          groups = [
            "system:bootstrappers",
            "system:nodes",
            "system:node-proxier",
          ]
        }
      ],
      [
        for arn in var.admin_role_arns : {
          rolearn  = arn,
          username = "eks-admin",
          groups   = ["system:masters"]
        }
      ],
      [
        for arn in var.read_only_role_arns : {
          rolearn  = arn,
          username = "eks-readonly",
          groups   = ["readonly"]
        }
      ],
      var.aws_auth_roles
    ))
    mapUsers    = yamlencode(var.aws_auth_users)
    mapAccounts = yamlencode(var.aws_auth_accounts)
  }
}

resource "kubernetes_config_map_v1_data" "aws_auth" {
  force = true

  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = local.aws_auth_configmap_data
}
