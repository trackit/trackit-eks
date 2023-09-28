locals {
  node_group = var.node_groups == {} ? {} : {
    for node in flatten([
      for i, subnet in data.aws_subnet.selected : [
        for name, node_group in var.node_groups :
        merge(
          {
            name                       = "${name}-${i}",
            subnet_ids                 = [subnet.id],
            create_launch_template     = true
            use_custom_launch_template = true
            use_name_prefix            = false
            create_iam_role            = false
            iam_role_arn               = var.node_group_iam_role_arn
            vpc_security_group_ids     = var.node_additional_security_group_ids
          },
          node_group,
        )
      ]
    ]) :
    node.name => node
  }
}
