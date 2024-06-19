locals {
  name = "pet-auto"
}

data "aws_acm_certificate" "acm-cert" {
  domain = "greatminds.sbs" 
  types       = ["AMAZON_ISSUED"]
  most_recent = true
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
  red_hat      = "ami-0574a94188d1b84a1"
  nexus_subnet = module.vpc.pubsn1_id
  pub_key      = module.keypair.pub_key_pair_id
  nexus_sg     = module.securitygroup.nexus-sg
  nexus_name   = "${local.name}-nexus"
  subnet-elb = [module.vpc.pubsn1_id, module.vpc.pubsn2_id]
  cert-arn = data.aws_acm_certificate.acm-cert.arn
     
}
module "jenkins" {
  source       = "./modules/jenkins"
  ami-redhat   = "ami-0574a94188d1b84a1"
  vpc_id = module.vpc.vpc_id
  subnet-id    = module.vpc.prvsn1_id
  jenkins-sg   = module.securitygroup.Jenkins-sg
  key-name     = module.keypair.pub_key_pair_id
  jenkins-name = "${local.name}-jenkins"
  nexus-ip     = module.nexus.nexus_ip
  cert-arn     = data.aws_acm_certificate.acm-cert.arn
  subnet-elb   = [module.vpc.pubsn1_id, module.vpc.pubsn2_id]
  nr-key       = "NRAK-W7PYXA013NC8GAFZL30HD58HOUO"
  nr-acc-id    = "4456322"
  nr-region    = "EU"
}

data "vault_generic_secret" "vault_secret" {
  path = "secret/database"
}

module "rds" {
  source        = "./modules/rds"
  rds_subgroup  = "rds_subgroup"
  rds_subnet_id = [module.vpc.pubsn1_id, module.vpc.pubsn2_id]
  db_subtag     = "${local.name}-db_subgroup"
  db_name       = "petclinic"
  db_username   = data.vault_generic_secret.vault_secret.data["username"]
  db_password   = data.vault_generic_secret.vault_secret.data["password"]
  rds_sg        = [module.securitygroup.rds-sg]
}

# Creating bastion host
module "bastion" {
  source        = "./modules/bastion"
  ami-id        = "ami-00ac45f3035ff009e"
  subnet_id     = module.vpc.pubsn1_id
  ssh_key       = module.keypair.pub_key_pair_id
  instance_type = "t2.micro"
  private-key   = module.keypair.private_key_pem
  bastion-name  = "${local.name}-bastion-host"
  bastion-sg    = module.securitygroup.bastion-sg
}

module "sonarqube" {
  source                = "./modules/sonarqube"
  ami                   = "ami-00ac45f3035ff009e"
  sonarqube_server_name = "${local.name}-sonar-server"
  instance_type         = "t2.medium"
  key_name              = module.keypair.pub_key_pair_id
  sonarqube-sg          = module.securitygroup.sonarqube-sg
  subnet_id             = module.vpc.pubsn1_id
  subnet-elb = [module.vpc.pubsn1_id, module.vpc.pubsn2_id]
  cert-arn = data.aws_acm_certificate.acm-cert.arn
}


module "prod-asg" {
  source                = "./modules/prodasg"
  ami                   = "ami-0574a94188d1b84a1"
  asg-sg                = module.securitygroup.asg-sg
  pub-key               = module.keypair.pub_key_pair_id
  nexus-ip              = module.nexus.nexus_ip
  newrelic-user-licence = "NRAK-W7PYXA013NC8GAFZL30HD58HOUO"
  newrelic-acct-id      = "4456322"
  vpc-zone-identifier   = [module.vpc.pubsn1_id, module.vpc.pubsn2_id]
  prod-asg-policy-name  = "prod-asg-policy"
  tg-arn                = module.prod-lb.tg-prod-arn
  prod-asg-name         = "${local.name}-prod-asg"
  newrelic-region       = "EU"


}

module "stage-asg" {
  source                = "./modules/stage-asg"
  ami                   = "ami-0574a94188d1b84a1"
  asg-sg                = module.securitygroup.asg-sg
  pub-key               = module.keypair.pub_key_pair_id
  nexus-ip              = module.nexus.nexus_ip
  newrelic-user-licence = "NRAK-W7PYXA013NC8GAFZL30HD58HOUO"
  newrelic-acct-id      = "4456322"
  vpc-zone-identifier   = [module.vpc.pubsn1_id, module.vpc.pubsn2_id]
  stage-asg-policy-name = "stage-asg-policy"
  tg-arn                = module.stage-lb.tg-stage-arn
  stage-asg-name        = "${local.name}-stage-asg"
  newrelic-region       = "EU"

}

module "route53" {
  source    = "./modules/route53"
  domain_name  ="greatminds.sbs"
  jenkins_domain_name  = "jenkins.greatminds.sbs"
  jenkins_lb_dns_name  = module.jenkins.alb-jen-dns
  jenkins_lb_zone_id   = module.jenkins.alb-jen-zoneid
  nexus_domain_name  = "nexus.greatminds.sbs"
  nexus_lb_dns_name  = module.nexus.nexus_dns_name
  nexus_lb_zone_id   = module.nexus.nexus_zone_id
  sonarqube_domain_name  = "sonarqube.greatminds.sbs"
  sonarqube_lb_dns_name  = module.sonarqube.sonarqube_dns_name
  sonarqube_lb_zone_id   = module.sonarqube.sonarqube_zone_id
  prod_domain_name  = "prod.greatminds.sbs"
  prod_lb_dns_name  = module.prod-lb.alb-prod-dns
  prod_lb_zone_id   = module.prod-lb.alb-prod-zoneid
  stage_domain_name  = "stage.greatminds.sbs"
  stage_lb_dns_name  = module.stage-lb.alb-stage-dns
  stage_lb_zone_id   = module.stage-lb.alb-stage-zoneid
}

module "prod-lb" {
  source = "./modules/prod-lb"
  port_http = 80
  port_https = 443
  name-alb-prod = "${local.name}-alb-prod"  
  prod-sg = module.securitygroup.asg-sg
  subnet = [module.vpc.pubsn1_id, module.vpc.pubsn2_id]
  cert-arn = data.aws_acm_certificate.acm-cert.arn
  vpc_id = module.vpc.vpc_id
}

module "stage-lb" {
  source = "./modules/stage-lb"
  port_http = 80
  port_https = 443
  name-alb-stage = "${local.name}-alb-stage"  
  stage-sg = module.securitygroup.asg-sg
  subnet = [module.vpc.pubsn1_id, module.vpc.pubsn2_id]
  cert-arn = data.aws_acm_certificate.acm-cert.arn
  vpc_id = module.vpc.vpc_id
}


module "ansible" {
  source = "./modules/ansible"
  red_hat = "ami-0574a94188d1b84a1"
  ansible_subnet = module.vpc.prvsn1_id
  pub_key = module.keypair.pub_key_pair_id
  ansible_sg = module.securitygroup.ansible-sg
  ansible_name = "${local.name}-ansible" 
  stage-playbook = "${path.root}/modules/ansible/stage-playbook.yaml"
  prod-playbook = "${path.root}/modules/ansible/prod-playbook.yaml"
  stage-discovery-script = "${path.root}/modules/ansible/auto-discovery-stage.sh"
  prod-discovery-script = "${path.root}/modules/ansible/auto-discovery-prod.sh"
  private_key = module.keypair.private_key_pem
  nexus-ip = module.nexus.nexus_ip
  newrelic-license-key = "NRAK-W7PYXA013NC8GAFZL30HD58HOUO"
  newrelic-acct-id = "4456322"  

  
}