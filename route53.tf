resource "aws_route53_zone" "private_zone" {
  count         = var.create_private_hosted_zone ? 1 : 0
  name          = "${var.cluster_name}.cluster.${var.env}.${var.aws_region_short}.${var.zone_name}"
  force_destroy = true

  vpc {
    vpc_id = var.vpc_id
  }

  tags = {
    Environment = var.env
    Creator     = "Terraform trackIt EKS module"
    operator    = "EKS"
    component   = "${var.cluster_name}.cluster.${var.env}.${var.aws_region_short}.${var.zone_name}"
  }
}

resource "aws_route53_record" "ns" {
  count = var.create_private_hosted_zone ? 1 : 0

  name    = "nameserver"
  zone_id = aws_route53_zone.private_zone[0].zone_id
  type    = "NS"
  ttl     = 24 * 60 * 60 # 1 day

  records = [
    aws_route53_zone.private_zone[0].name_servers[0],
    aws_route53_zone.private_zone[0].name_servers[1],
    aws_route53_zone.private_zone[0].name_servers[2],
    aws_route53_zone.private_zone[0].name_servers[3],
  ]
}

resource "aws_route53_zone_association" "additional_vpcs" {
  count = var.create_private_hosted_zone ? length(var.private_hosted_zone_additional_vpc_ids_association) : 0

  zone_id = aws_route53_zone.private_zone[0].zone_id
  vpc_id = element(
    split(
      ",",
      element(var.private_hosted_zone_additional_vpc_ids_association, count.index),
    ),
    0,
  )
  vpc_region = element(
    split(
      ",",
      element(var.private_hosted_zone_additional_vpc_ids_association, count.index),
    ),
    1,
  )
}
