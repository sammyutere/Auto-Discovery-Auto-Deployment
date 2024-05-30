# Docker server
resource "aws_instance" "docker-server" {
  ami                    = var.red_hat
  instance_type          = "t2.medium"
  subnet_id              = var.docker_subnet
  key_name               = var.pub_key
  vpc_security_group_ids = [var.docker_sg]
  # user_data              = local.docker_user_data

  tags = {
    Name = var.docker_name
  }
}
