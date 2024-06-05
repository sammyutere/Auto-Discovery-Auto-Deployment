locals {
  name = "pet-auto"
}
module "vpc" {
  source      = "./modules/vpc"
  avz1        = "eu-west-3a"
  avz2        = "eu-west-3b"
  name-vpc    = "${local.name}-vpc"
  name-igw    = "${local.name}-igw"
  name-ngw    = "${local.name}-ngw"
  name-eip    = "${local.name}-eip"
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
module "keypair" {
  source = "./modules/keypair"
}
module "nexus" {
  source       = "./modules/nexus"
  red_hat      = ""
  nexus_subnet = module.vpc.pubsn1_id
  pub_key      = module.keypair.public_key_pem
  nexus_sg     = ""
  nexus_name   = "${local.name}-nexus"
}
module "jenkins" {
  source       = "./modules/jenkins"
  ami-redhat   = ""
  subnet-id    = module.vpc.prvsn1_id
  jenkins-sg   = module.securitygroup.Jenkins-sq
  key-name     = module.keypair.pub_key_pair_id
  jenkins-name = "${local.name}-jenkins"
  nexus-ip     = module.nexus.nexus_ip
  cert-arn     = ""
  subnet-elb   = [module.vpc.pubsn1_id, module.vpc.pubsn2_id]
  nr-key       = ""
  nr-acc-id    = ""
  nr-region    = ""
}
module "docker" {
  source        = "./modules/docker"
  red_hat       = ""
  docker_subnet = module.vpc.prvsn1_id
  pub_key       = ""
  docker_sg     = ""
  docker_name   = "${local.name}-nexus"
}
module "rds" {
  source        = "./modules/rds"
  rds_subgroup  = "rds_subgroup"
  rds_subnet_id = [module.vpc.pubsn1_id, module.vpc.pubsn2_id]
  db_subtag     = "${local.name}-db_subgroup"
  db_name       = "petclinic"
  db_username   = ""
  db_password   = ""
  rds_sg        = module.securitygroup.rds-sq
}

# Creating bastion host
module "bastion" {
  source        = "./modules/bastion"
  ami-id        = ""
  subnet_id     = module.vpc.pubsn1_id
  ssh_key       = module.keypair.pub_key_pair_id
  instance_type = "t2.micro"
  bastion-name  = "${local.name}-bastion-host"
  bastion-sg    = module.securitygroup.bastion-sq
}
module "vault" {
  source       = "./modules/vault"
  ami-redhat   = ""
  vault_subnet = module.vpc.pubsn2_id
  pub_key      = module.keypair.pub_key_pair_id
  vault_sg     = module.securitygroup.asg-sq
  vault-server = "${local.name}-vault-server"
}

  source            = "./modules/bastion"  
  ami-id = ""
  subnet_id         = module.vpc.pubsn1_id
  ssh_key           = module.keypair.pub_key_pair_id
  instance_type     = "t2.micro"
  bastion-name = "${local.name}-bastion-host"
  bastion-sg = module.securitygroup.bastion-sq
}

# create vault server
resource "aws_instance" "vault" {
  ami     = var.ami-ubuntu
  instance_type = "t2.medium"
  vpc_security_group_ids = [aws_security_group.vault-SG.id]
  key_name = aws_key_pair.vault-public-key.key_name
  associate_public_ip_address = true
  iam_instance_profile = aws_iam_instance_profile.vault-kms-unseal.id
  user_data = tempatefile("./vault-user-data.sh", {
    var2  = aws_kms_key.vault.id,
    var1  = var.region
  })
  tags = {
    Name  = "${local.name}-vault"
  }
}
