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

module "nexus" {
  source = "./modules/nexus"
  red_hat = ""
  nexus_subnet = module.vpc.pubsn1_id
  pub_key = ""
  nexus_sg = ""
  nexus_name = "${local.name}-nexus"
}

module "docker" {
  source = "./modules/docker"
  red_hat = ""
  docker_subnet = module.vpc.prvsn1_id
  pub_key = ""
  docker_sg = ""
  docker_name = "${local.name}-nexus"
}
