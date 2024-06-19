output "jenkins-server" {
  value = module.jenkins.jenkins_ip
}

output "bastion" {
  value = module.bastion.bastion_ip
}

output "nexus" {
  value = module.nexus.nexus_ip
}

output "rds" {
  value = module.rds.rds_endpoint
}

output "sonarqube" {
  value = module.sonarqube.Sonerqube-ip
}

output "ansible" {
  value = module.ansible.ansible_ip
}
