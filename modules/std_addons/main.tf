locals {
  external_dns_extra_args = concat(
    [for v in var.hosted_zones : "--zone-id-filter=${v.zone_id}" if lookup(v, "zone_id", "") != ""],
    [for v in try(var.external_dns.extra_args, []) : v],
  )
}

module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.16.3"

  count = var.create ? 1 : 0

  create_kubernetes_resources = var.create_kubernetes_resources

  cluster_name      = var.cluster_name
  cluster_endpoint  = var.cluster_endpoint
  cluster_version   = var.cluster_version
  oidc_provider_arn = var.oidc_provider_arn

  tags = merge(var.tags, {
    Creator = "Terraform"
  })

  # We want to wait for dependencies to be deployed first
  create_delay_dependencies = var.create_delay_dependencies

  # Using cluster_addons in EKS module instead
  eks_addons = merge(
    var.enable_ebs_csi ? {
      aws-ebs-csi-driver = {
        service_account_role_arn = try(var.ebs_csi.iam_role_arn, "")
        configuration_values = jsonencode({
          controller = {
            tolerations = [
              {
                key      = "eks-addons",
                operator = "Exists",
                effect   = "NoSchedule",
              }
            ]
            nodeSelector = {
              "karpenter.sh/nodepool" = "eks-addons"
            }
            affinity = {
              podAntiAffinity = {
                requiredDuringSchedulingIgnoredDuringExecution = [
                  {
                    labelSelector = {
                      matchLabels = {
                        app = "ebs-csi-controller"
                      }
                    }
                    topologyKey = "kubernetes.io/hostname"
                  }
                ],
                preferredDuringSchedulingIgnoredDuringExecution = []
              }
            }
            topologySpreadConstraints = []
          }
        })
      }
    } : {},
  )

  ################################################################################
  # ALB controller
  ################################################################################
  enable_aws_load_balancer_controller = var.enable_aws_load_balancer_controller

  aws_load_balancer_controller = merge(
    var.aws_load_balancer_controller,
    {
      wait = true
      set = concat(
        [
          # turn off the mutating webhook for services because we are using
          # service.beta.kubernetes.io/aws-load-balancer-type: external
          # https://github.com/aws-ia/terraform-aws-eks-blueprints-addons/issues/274
          {
            name  = "enableServiceMutatorWebhook"
            value = "false"
          },
          {
            name  = "podDisruptionBudget.maxUnavailable"
            value = "1"
          },
          {
            name  = "resources.requests.memory"
            value = "100Mi"
          },
          {
            name  = "resources.requests.cpu"
            value = "15m"
          },
          {
            name  = "resources.limits.memory"
            value = "100Mi"
          },
          {
            name  = "serviceMonitor.enabled"
            value = "true"
          },
        ],
        try(var.aws_load_balancer_controller.set, [])
      )
      values = concat(
        [
          <<-EOT
          tolerations:
            - key: "eks-addons"
              operator: "Exists"
              effect: "NoSchedule"
          nodeSelector:
            karpenter.sh/nodepool: eks-addons
          affinity:
            podAntiAffinity:
              requiredDuringSchedulingIgnoredDuringExecution:
                - labelSelector:
                    matchLabels:
                      app.kubernetes.io/name: aws-load-balancer-controller
                  topologyKey: kubernetes.io/hostname
          topologySpreadConstraints: []
          EOT
        ],
        try(var.aws_load_balancer_controller.values, [])
      )
    }
  )

  ################################################################################
  # External DNS
  ################################################################################
  enable_external_dns = var.enable_external_dns

  external_dns_route53_zone_arns = [for v in var.hosted_zones : v.arn]
  external_dns = merge(
    var.external_dns,
    {
      set = concat(
        [
          {
            name  = "txtOwnerId"
            value = try(var.external_dns.txt_owner_id, var.cluster_name)
          },
          {
            name  = "policy"
            value = try(var.external_dns.policy, "sync")
          },
          {
            name  = "triggerLoopOnEvent"
            value = try(var.external_dns.trigger_on_event, true)
          },
          {
            name  = "interval"
            value = try(var.external_dns.interval, "24h")
          },
          {
            name  = "resources.requests.memory"
            value = try(var.external_dns.resources_requests_memory, "400Mi")
          },
          {
            name  = "resources.requests.cpu"
            value = try(var.external_dns.resources_requests_cpu, "15m")
          },
          {
            name  = "resources.limits.memory"
            value = try(var.external_dns.resources_limits_memory, "400Mi")
          },
        ],
        [
          for k, v in local.external_dns_extra_args :
          {
            name  = "extraArgs[${k}]"
            value = v
          }
        ],
        [
          for k, v in var.hosted_zones :
          {
            name  = "domainFilters[${k}]"
            value = v.name
          }
        ],
        try(var.external_dns.set, [])
      )

      values = concat(
        [
          <<-EOT
          tolerations:
            - key: "eks-addons"
              operator: "Exists"
              effect: "NoSchedule"
          nodeSelector:
            karpenter.sh/nodepool: eks-addons
          EOT
        ],
        try(var.external_dns.values, [])
      )
    }
  )

  ################################################################################
  # External Secrets
  ################################################################################
  enable_external_secrets = var.enable_external_secrets
  external_secrets_secrets_manager_arns = concat(
    [
      "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.env}/${var.service}/*",
      "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:${var.service}/*",
    ],
    try(var.external_secrets.secrets_manager_arns, [])
  )
  external_secrets = merge(
    var.external_secrets,
    {
      set = concat(
        [
          {
            name  = "resources.requests.memory"
            value = "100Mi"
          },
          {
            name  = "resources.requests.cpu"
            value = "15m"
          },
          {
            name  = "resources.limits.memory"
            value = "100Mi"
          },
          {
            name  = "webhook.resources.requests.memory"
            value = "100Mi"
          },
          {
            name  = "webhook.resources.requests.cpu"
            value = "15m"
          },
          {
            name  = "webhook.resources.limits.memory"
            value = "100Mi"
          },
          {
            name  = "certController.resources.requests.memory"
            value = "100Mi"
          },
          {
            name  = "certController.resources.requests.cpu"
            value = "15m"
          },
          {
            name  = "certController.resources.limits.memory"
            value = "100Mi"
          },
        ],
        try(var.external_secrets.set, [])
      )

      values = concat(
        [
          <<-EOT
          tolerations:
            - key: "eks-addons"
              operator: "Exists"
              effect: "NoSchedule"
          nodeSelector:
            karpenter.sh/nodepool: eks-addons
          webhook:
            tolerations:
              - key: "eks-addons"
                operator: "Exists"
                effect: "NoSchedule"
            nodeSelector:
              karpenter.sh/nodepool: eks-addons
          certController:
            tolerations:
              - key: "eks-addons"
                operator: "Exists"
                effect: "NoSchedule"
            nodeSelector:
              karpenter.sh/nodepool: eks-addons
          EOT
        ],
        try(var.external_secrets.values, [])
      )
    }
  )
}
