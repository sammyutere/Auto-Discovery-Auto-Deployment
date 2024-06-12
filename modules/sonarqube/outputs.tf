output "instance_id" {
  description = "The ID of Sonarqube instance server"
  value       = aws_instance.sonarqube.id
}

output "Sonerqube-ip" {
    value = aws_instance.sonarqube.public_ip
}
