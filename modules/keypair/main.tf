# dynamic keypair resource
resource "tls_private_key" "keypair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "local_file" "private_key" {
  content         = tls_private_key.keypair.private_key_pem
  filename        = "petclinic-private-key"
  file_permission = "600"
}

resource "aws_key_pair" "public_key" {
  key_name   = "petclinic-public-key"
  public_key = tls_private_key.keypair.public_key_openssh
}
