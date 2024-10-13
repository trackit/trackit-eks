data "aws_vpc" "vpc" {
  id = var.network.vpc_id
}

data "aws_subnet" "selected" {
  count = length(var.network.subnet_ids)
  id    = element(var.network.subnet_ids, count.index)
}
