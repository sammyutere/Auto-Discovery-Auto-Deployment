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
  name-pub-rt = "${local.name}-pub-rt"
  name-prv-rt = "${local.name}-prv-rt"
}

module "securitygroup" {
  source = "./modules/securitygroup"
  vpc-id = module.vpc.vpc_id
}


module "securitygroup" {
  source = "./modules/securitygroup"
  vpc-id = module.vpc.vpc_id
}


module "nexus" {
  source = "./modules/nexus"
  red_hat = ""
  nexus_subnet = module.vpc.pubsn1_id
  pub_key = module.keypair.public_key_pem
  nexus_sg = ""
  nexus_name = "${local.name}-nexus"
}

module "keypair" {
  source = "./modules/keypair"
  key_name = "petkey"
  create_private_key = true
}

module "docker" {
  source = "./modules/docker"
  red_hat = ""
  docker_subnet = module.vpc.prvsn1_id
  pub_key = ""
  docker_sg = ""
  docker_name = "${local.name}-nexus"
}
# create subnet group
resource "aws_db_subnet_group" "default" {
  name       = "main"
  subnet_ids = [aws_subnet.frontend.id, aws_subnet.backend.id]

  tags = {
    Name = "My DB subnet group"
  }
}



# aws db 
resource "aws_rds_cluster" "default" {
  cluster_identifier      = "aurora-cluster-demo"
  engine                  = "aurora-mysql"
  engine_version          = "5.7.mysql_aurora.2.03.2"
  availability_zones      = ["eu-west-3a", "eu-west-3b"]
  database_name           = "mydb"
  master_username         = "foo"
  master_password         = "bar"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
}
