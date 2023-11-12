resource "kubectl_manifest" "aws_node_template" {
  count = var.create && var.create_kubernetes_resources && var.create_aws_node_template ? 1 : 0

  yaml_body = try(var.aws_node_template.yaml_body, <<-YAML
    apiVersion: karpenter.k8s.aws/v1alpha1
    kind: AWSNodeTemplate
    metadata:
      name: default
    spec:
      subnetSelector:
        aws-ids: "${join(",", var.subnet_ids)}"
      securityGroupSelector:
        karpenter.sh/discovery: ${var.cluster_name}
      tags:
        karpenter.sh/discovery: ${var.cluster_name}
    YAML
  )

  depends_on = [
    module.eks_blueprints_addons[0].karpenter
  ]
}
