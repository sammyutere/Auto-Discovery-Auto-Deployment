provider "aws" {
  region = "eu-west-3"
}
module "vpc" {
  source = "./modules/vpc"
  
  vpc_cidr = "10.0.0.0/16"

  name   = "eu-pcj"
}

module "subnets" {
  source = "./modules/subnets"

  vpc_id    = module.vpc.vpc_id
  pubs1_cidr = "10.0.1.0/24"
  pubs2_cidr = "10.0.2.0/24"
  priv1_cidr = "10.0.3.0/24"
  priv2_cidr = "10.0.4.0/24"
  avz1       = "eu-west-3a"
  avz2       = "eu-west-3b"
  name       = "eu-pcj"
}

module "internet_gateway" {
  source = "./modules/internet_gateway"
  
  vpc_id = module.vpc.vpc_id

  name = "eu-pcj"
}

module "nat_gateway" {
  source        = "./modules/nat_gateway"
  allocation_id = aws_eip.eip.id
  subnet_id     = module.subnets.public_subnet_ids[0]

  name = "eu-pcj"
}
resource "aws_eip" "eip" {
  domain = "vpc"

  tags = {
    Name = "eu-pcj-eip"
  }
}

