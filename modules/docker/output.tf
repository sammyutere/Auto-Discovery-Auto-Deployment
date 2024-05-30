output "docker_ip" {
  value = aws_instance.docker-server.public_ip
}