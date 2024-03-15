locals {
  fargate_profiles = var.fargate_profiles != {} ? var.fargate_profiles : {
    karpenter = {
      selectors = [
        { namespace = "karpenter" }
      ]
    }
    kube-system = {
      selectors = [
        { namespace = "kube-system" }
      ]
    }
  }
}
