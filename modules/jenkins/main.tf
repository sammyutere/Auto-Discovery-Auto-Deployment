resource  "aws_instance" "jenkins_server" {
  ami                         = var.ami-redhat
  instance_type               = "t3.medium"
  subnet_id                   = var.subnet-id
  vpc_security_group_ids      = [var.jenkins-sg]
  key_name                    = var.key-name 
  user_data                   = local.jenkins_user_data

  tags = {
    Name = var.jenkins-name
  }
}
  
resource "aws_lb" "alb-jenkins" {
  name                       = "jenkins-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [var.jenkins-sg]
  subnets                    = var.subnet-elb
  enable_deletion_protection = false

  tags = {
    Name = "jenkins-alb"
  }
}


#Creating Load Balancer Listener for https
resource "aws_lb_listener" "jalb_lsnr-https" {
  load_balancer_arn = aws_lb.alb-jenkins.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.cert-arn

  default_action {
    type             = "forward"
      target_group_arn = aws_lb_target_group.jenlb-tg.arn
  }
}

# Creating Load Balancer Listener for http
resource "aws_lb_listener" "lb_lsnr-http" {
  load_balancer_arn = aws_lb.alb-jenkins.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.jenlb-tg.arn
  }
}

# Creating Load Balancer Target Group for ASG stage
resource "aws_lb_target_group" "jenlb-tg" {
  name     = "jenkins-tg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    interval            = 30
    timeout             = 3
    healthy_threshold   = 3
    unhealthy_threshold = 5
  }
}
resource "aws_lb_target_group_attachment" "tg_att" {
  target_group_arn = aws_lb_target_group.jenlb-tg.arn
  target_id        = aws_instance.jenkins_server.id
  port             = 8080
}

