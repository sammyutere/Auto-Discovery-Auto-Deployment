provider "aws" {
  region = "eu-west-3"
  profile = "set19"
}

terraform {
  backend "s3" {
    bucket = "set19-remote-tf"
    key = "set19-vault/tfstate"
    dynamodb_table = "petclinic"
    region = "eu-west-3"
    encrypt = true
    profile ="set19"
  }
}

resource "aws_instance" "vault_server" {
  ami           = var.ami-ubuntu
  instance_type = "t2.medium"
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  key_name               = aws_key_pair.public_key.id
  vpc_security_group_ids = [aws_security_group.vault-sg.id]
  # user_data              = local.vault_user_data

  tags = {
    Name = "vault_server"
  }
}

#create aws KMS
resource "aws_kms_key" "vault" {
  description             = "KMS key"
  enable_key_rotation     = true
  deletion_window_in_days = 20
  tags = {
    Name = "vault-kms-key"
  }
}

# Vault SG
resource "aws_security_group" "vault-sg" {
  name        = "vault-sg"
  description = "Vault Security Group"


  # Inbound Rules
  ingress {
    description = "ssh access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "vault port"
    from_port   = 8200
    to_port     = 8200
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  
  }
  ingress {
    description = "https port"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "http port"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "Vault-sg"
  }
}

# dynamic keypair resource
resource "tls_private_key" "keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.keypair.private_key_pem
  filename        = "vault-private-key"
  file_permission = "600"
}

resource "aws_key_pair" "public_key" {
  key_name   = "vault-public-key"
  public_key = tls_private_key.keypair.public_key_openssh
}
