provider "aws" {
  region = "eu-west-2"
  profile = "default"
}

resource "aws_instance" "vault_server" {
  ami           = "ami-07c1b39b7b3d2525d" #Ubuntu
  instance_type = "t2.medium"
  iam_instance_profile = aws_iam_instance_profile.ec2_instance_profile.name
  key_name               = aws_key_pair.public_key.id
  vpc_security_group_ids = [aws_security_group.vault-sg.id]
  user_data              = templatefile("./vault-script.sh", {
    var1 = "eu-west-2"
    var2 = aws_kms_key.vault.id
    keypair = tls_private_key.keypair.private_key_pem
  })
  provisioner "local-exec" {
    when    = destroy
    command = "rm -f ./root_token.txt"
  }
  tags = {
    Name = "vault_server"
  }
}


#create aws KMS
resource "aws_kms_key" "vault" {
  description             = "KMS key"
  deletion_window_in_days = 10
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

data "aws_route53_zone" "route53_zone" {
  name              = "linuxclaud.sbs"
  private_zone =  false
}

resource "aws_route53_record" "vault_record" {
  zone_id = data.aws_route53_zone.route53_zone.zone_id
  name    = "vault.linuxclaud.sbs"
  type    = "A"
  alias  {
    name       =   aws_elb.vault_lb.dns_name
    zone_id    =   aws_elb.vault_lb.zone_id
    evaluate_target_health = true
  }
}
resource "aws_acm_certificate" "acm-cert" {
  domain_name = "linuxclaud.sbs"
  subject_alternative_names = ["*.linuxclaud.sbs"]
  validation_method = "DNS"
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_acm_certificate_validation" "valid-acm-cert" {
  certificate_arn = aws_acm_certificate.acm-cert.arn
  validation_record_fqdns = [for record in aws_route53_record.cert-record : record.fqdn] 
}
#attaching route53 and the certificate- connecting route53 to the certificate
resource "aws_route53_record" "cert-record" {
  for_each = {
    for anybody in aws_acm_certificate.acm-cert.domain_validation_options : anybody.domain_name => {
    name = anybody.resource_record_name
    record =anybody.resource_record_value
    type = anybody.resource_record_type 
  }
}

allow_overwrite  = true 
name   = each.value.name
records   = [each.value.record]
ttl   =60
type   =  each.value.type
zone_id     =  data.aws_route53_zone.route53_zone.zone_id
}

resource "aws_elb" "vault_lb" {
  name            = "vault-lb"
  availability_zones = ["eu-west-2a", "eu-west-2b"]
  security_groups = [aws_security_group.vault-sg.id]
  listener {
    instance_port      = 8200
    instance_protocol  = "http"
    lb_port            = 443
    lb_protocol        = "https"
    ssl_certificate_id = aws_acm_certificate.acm-cert.arn
  }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "TCP:8200"
    interval            = 30
  }

    instances                   = [aws_instance.vault_server.id]
    cross_zone_load_balancing   = true
    idle_timeout                = 400
    connection_draining         = true
    connection_draining_timeout = 400

    tags = {
      Name = "vault-elb"
  }
}


