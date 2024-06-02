output "ansible_ip" {
  value = aws_instance.ansible-server.public_ip
}