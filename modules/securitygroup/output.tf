output "sonarqube-sq" {
  value = aws_security_group.sonarqube-sg.id 
}
output "ansible-sq" {
  value = aws_security_group.ansible-sg.id 
}
output "nexus-sq" {
  value = aws_security_group.nexus-sg.id 
}
output "Jenkins-sq" {
  value = aws_security_group.jenkins-sg.id 
}
output "asg-sq" {
  value = aws_security_group.asg-sg.id 
}
output "bastion-sq" {
  value = aws_security_group.bastion-sg.id 
}
output "rds-sq" {
  value = aws_security_group.rds-sg.id 
}
