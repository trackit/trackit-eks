data "aws_subnet" "selected" {
  count = length(var.private_subnets)
  id    = element(var.private_subnets, count.index)
}

data "aws_key_pair" "debug" {
  count    = var.key_pair_name != null ? 1 : 0
  key_name = var.key_pair_name
}
