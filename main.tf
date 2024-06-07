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
module "keypair" {
  source = "./modules/keypair"
}
module "nexus" {
  source       = "./modules/nexus"
  red_hat      = "ami-05f804247228852a3"
  nexus_subnet = module.vpc.pubsn1_id
  pub_key      = module.keypair.pub_key_pair_id
  nexus_sg     = module.securitygroup.nexus-sq
  nexus_name   = "${local.name}-nexus"
}
module "jenkins" {
  source       = "./modules/jenkins"
  ami-redhat   = "ami-05f804247228852a3"
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

module "rds" {
  source        = "./modules/rds"
  rds_subgroup  = "rds_subgroup"
  rds_subnet_id = [module.vpc.pubsn1_id, module.vpc.pubsn2_id]
  db_subtag     = "${local.name}-db_subgroup"
  db_name       = "petclinic"
  db_username   = "admin"#data.vault_generic_secret.vault_secret.data["username"]
  db_password   = "admin123"#data.vault_generic_secret.vault_secret.data["password"]
  rds_sg        = [module.securitygroup.rds-sq]
}

# Creating bastion host
module "bastion" {
  source        = "./modules/bastion"
  ami-id        = "ami-00ac45f3035ff009e"
  subnet_id     = module.vpc.pubsn1_id
  ssh_key       = module.keypair.pub_key_pair_id
  instance_type = "t2.micro"
  private-key = module.keypair.private_key_pem
  bastion-name  = "${local.name}-bastion-host"
  bastion-sg    = module.securitygroup.bastion-sq
}

module "sonarqube" {
  source = "./modules/sonarqube"
  ami   = "ami-00ac45f3035ff009e"
  sonarqube_server_name = "${local.name}-prvsn1"
  instance_type = "t2.medium"
  key_name = module.keypair.pub_key_pair_id
  sonarqube-sg = module.securitygroup.sonarqube-sq
  subnet_id = module.vpc.pubsn1_id
}

# data "vault_generic_secret" "vault_secret" {
#   path = secret/database
# }