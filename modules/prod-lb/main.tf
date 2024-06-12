# Creating Application Load Balancer for ASG Prod
resource "aws_lb" "alb-prod" {
  name                       = "asg-prod-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.asg-sg.id]
  subnets                    = [aws_subnet.public-subnet1.id, aws_subnet.public-subnet2.id]
  enable_deletion_protection = false

  tags = {
    Name = var.name-alb-prod
  }
}


#Creating Load Balancer Listener for https
resource "aws_lb_listener" "lb_lsnr-http" {
  load_balancer_arn = module.aws_lb.alb-prod.arn
  port              = var.port_http
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = module.aws_acm_certificate.ssl-cert.arn

  default_action {
    type             = "forward"
      target_group_arn = module.aws_lb_target.lb-tg-prod.arn
  }
}

# Creating Load Balancer Listener for http
resource "aws_lb_listener" "lb_lsnr-https" {
  load_balancer_arn = module.aws_lb.alb-prod.arn
  port              = var.port_https
  protocol          = "HTTPS"

  default_action {
    type             = "forward"
    target_group_arn = module.aws_lb_target_group.lb-tg-prod.arn
  }
}

# Creating Load Balancer Target Group for ASG Prod
resource "aws_lb_target_group" "lb-tg-prod" {
  name     = "lb-tg-prod"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = module.aws_vpc.vpc_id

  health_check {
    interval            = 30
    timeout             = 10
    healthy_threshold   = 3
    unhealthy_threshold = 5
  }
}
