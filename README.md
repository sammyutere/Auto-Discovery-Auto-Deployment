

# Auto-Discovery-Auto-Deployment

# Note that to be able to adapt this code or replicate this project for your personal use, you must change the following values outlined below
/*
    • In the root main file, you must change the following to your own values to be able to use this code to run your own application: 
        ◦ change the domain to your own domain under (data "aws_acm_certificate") 
        ◦ change the availability zones to values relevant to your region, under module “vpc” module avz1 and avz2 
        ◦ change ami values to the values relevant to your aws region, under module “nexus”, module “jenkins” 
        ◦ change newrelic values, nr-key, nr-acc-id, nr-region, under module “jenkins” 
        ◦ change ami values to the values relevant to your aws region, under module “prod-asg” 
        ◦ change ami-id relevant to your region, under module “bastion” 
        ◦ change ami relevant to your region, under module “sonarqube” 
        ◦ change ami values to the values relevant to your aws region, under module “stage-asg” 
        ◦ change newrelic values, newrelic-user-license, newrelic-acct-id, under module “prod-asg” and “stage-asg” 
        ◦ change domain_name, jenkins_domain_name, nexus_domain_name, sonarqube_domain_name, prod_domain_name, and stage_domain_name values to your domain, under module “route53” 
        ◦ change ami value of red_hat to ami relevant to your region, under module “ansible” 
        ◦ change new relic values, newrelic-license-key, newrelic-acct-id, under module “ansible” 
    • change within vault/main.tf region, profile(profile that you set via AWS CLI), under provider “aws” 
    • change within vault/main.tf, ami(relevant to your region), var1(region), under resource "aws_instance" "vault_server" 
    • change within vault/main.tf, name(add domain), under data "aws_route53_zone" "route53_zone" 
    • change within vault/main.tf, name(add domain), under resource "aws_route53_record" "vault_record" 
    • change within vault/main.tf, domain_name(add domain), subject_alternative_names(add domain), under resource "aws_acm_certificate" "acm-cert" 
    • change within vault/main.tf, availability_zones, under resource "aws_elb" "vault_lb" 
    • change within vault/variable.tf, default(ami), under variable "ami-ubuntu" 
    • change within backend.tf, in the main project folder, region, profile(profile that you have set via AWS CLI) 
    • change within remote_state/main.tf, region, profile, under provider “aws” 
    • change within backend.tf, region, profile, under backend “s3” 
    • change within provider.tf which is in the same directory hierarchy as the root main.tf, region, profile, token, and address (domain name) 
    • change within variable.tf which is in the same directory hierarchy as the root main.tf, default.? 
    • change the NEW_RELIC_API_KEY and NEW_RELIC_ACCOUNT_ID within modules/nexus/nexus-script.tf and modules/sonarqube/sonarqube.tf 
    Note that to get your new relic values, click to generate new key copy and save copy new relic account id also.
*/