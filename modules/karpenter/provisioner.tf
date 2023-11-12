resource "kubectl_manifest" "provisioner" {
  count = var.create && var.create_kubernetes_resources && var.create_provisioner ? 1 : 0

  yaml_body = try(var.provisioner.yaml_body, <<-YAML
    apiVersion: karpenter.sh/v1alpha5
    kind: Provisioner
    metadata:
      name: ${var.cluster_name}-default
    spec:
      requirements:
        - key: "topology.kubernetes.io/zone"
          operator: In
          values: ${jsonencode(var.availability_zones)}
        - key: karpenter.k8s.aws/instance-category
          operator: In
          values: ["c", "m", "r"]
        - key: karpenter.k8s.aws/instance-generation
          operator: Gt
          values: ["2"]
        - key: kubernetes.io/arch
          operator: In
          values: ["arm64", "amd64"]
        - key: "karpenter.sh/capacity-type" # If not included, the webhook for the AWS cloud provider will default to on-demand
          operator: In
          values: ["spot", "on-demand"]
      kubeletConfiguration:
        containerRuntime: containerd
        maxPods: 110
      limits:
        resources:
          cpu: 1000
      consolidation:
        enabled: true
      providerRef:
        name: default
      ttlSecondsUntilExpired: 2592000 # 30 Days = 60 * 60 * 24 * 30 Seconds
    YAML
  )

  depends_on = [
    module.eks_blueprints_addons[0].karpenter
  ]
}