resource "aws_instance" "vault_server" {
  ami           = var.ami-redhat
  instance_type = "t2.micro"
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  subnet_id              = var.vault_subnet
  key_name               = var.pub_key
  vpc_security_group_ids = [var.vault_sg]
  # user_data              = local.vault_user_data

  tags = {
    Name = var.vault-server
  }
}
