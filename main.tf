locals {
  name = "pet-auto"
}
module "vpc" {
  source = "./modules/vpc"
  avz1 = "eu-west-3a"
  avz2 = "eu-west-3b"
  name-vpc = "${local.name}-vpc"
  name-igw = "${local.name}-igw"
  name-ngw = "${local.name}-ngw"
  name-eip = "${local.name}-eip"
  name-pubsn1 = "${local.name}-pubsn1"
  name-pubsn2 = "${local.name}-pubsn2"
  name-prvsn1 = "${local.name}-prvsn1"
  name-prvsn2 = "${local.name}-prvsn2"

}

module "securitygroup" {
  source = "./modules/securitygroup"
  vpc-id = module.vpc.vpc_id
}


