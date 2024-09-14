module "eks_blueprints_addons" {
  source  = "aws-ia/eks-blueprints-addons/aws"
  version = "~> 1.0.0" # Replace with the desired version

  cluster_name      = var.cluster_name
  cluster_endpoint  = data.aws_eks_cluster.cluster.endpoint
  cluster_version   = data.aws_eks_cluster.cluster.version
  oidc_provider_arn = data.aws_iam_openid_connect_provider.oidc_provider.arn

  karpenter = {
    enable    = true
    version   = "v1.0.0"    # Specify the Karpenter version
    namespace = "karpenter" # Namespace where Karpenter will be installed
  }
}

resource "kubectl_manifest" "ec2_node_class" {
  yaml_body = try(var.ec2_node_class_yaml_body, <<-YAML
    apiVersion: karpenter.k8s.aws/v1beta1
    kind: EC2NodeClass
    metadata:
      name: default
    spec:
      amiFamily: AL2
      role: ${module.eks_blueprints_addons.karpenter["node_iam_role_name"]}
      subnetSelectorTerms: ${jsonencode(local.subnet_selector_terms)}
      securityGroupSelectorTerms:
        - tags:
            karpenter.sh/discovery: ${var.cluster_name}
      tags:
        karpenter.sh/discovery: ${var.cluster_name}
    YAML
  )

  depends_on = [
    module.eks_blueprints_addons
  ]
}

resource "kubectl_manifest" "node_pool" {
  yaml_body = try(var.node_pool_yaml_body, <<-YAML
    apiVersion: karpenter.sh/v1beta1
    kind: NodePool
    metadata:
      name: eks-addons
    spec:
      template:
        spec:
          nodeClassRef:
            name: default
          taints:
            - key: eks-addons
              effect: NoSchedule
          requirements:
            - key: "karpenter.k8s.aws/instance-generation"
              operator: Gt
              values: ["2"]
            - key: "karpenter.k8s.aws/instance-memory"
              operator: Gt
              values: ["${try(var.node_pool_min_instance_memory - 1, "2047")}"] # 2 * 1024 - 1
            - key: "kubernetes.io/arch"
              operator: In
              values: ["arm64", "amd64"]
            - key: "karpenter.sh/capacity-type"
              operator: In
              values: ["spot", "on-demand"]
            - key: "karpenter.k8s.aws/instance-hypervisor"
              operator: In
              values: ["nitro"] # VPC CNI only supports instance types that run on the Nitro hypervisor
          kubelet:
            maxPods: 110
      limits:
        cpu: "10"
      disruption:
        consolidationPolicy: WhenUnderutilized
        expireAfter: 720h
    YAML
  )

  depends_on = [
    module.eks_blueprints_addons,
    kubectl_manifest.ec2_node_class
  ]
}
