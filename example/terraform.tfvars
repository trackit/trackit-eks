aws_region = "eu-west-3"

vpc = {
  id                 = "value"
  name               = "trackit-vpc"
  cidr               = "10.0.0.0/16"
  azs                = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
  private_subnets    = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets     = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  subnet_ids         = ["subnet-XXXXXXXXXX", "subnet-XXXXXXX", "subnet-XXXXXXXX"]
  enable_nat_gateway = true
  create_igw         = true
}

tags = {
  env = "staging"
}

cluster_name = "trackit-eks-dev-green-arc"
