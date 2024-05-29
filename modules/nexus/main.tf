#Create nexus server
resource "aws_instance" "nexus" {
  ami                         = var.red_hat
  instance_type               = "t2.medium"
  associate_public_ip_address = true
  subnet_id                   = var.nexus_subnet
  key_name                    = var.pub_key
  vpc_security_group_ids      = [var.nexus_sg]
  # user_data = var.nexus_userdata
  tags = {
    Name = var.nexus_name
  }
}