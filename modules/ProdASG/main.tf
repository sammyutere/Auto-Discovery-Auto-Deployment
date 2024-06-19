# Create Launch Template
resource "aws_launch_template" "prod_lt" {
  image_id               = var.ami
  instance_type          = "t2.medium"
  vpc_security_group_ids = [var.asg-sg]
  key_name               = var.pub-key
  user_data = base64encode(templatefile("./modules/ProdASG/docker-script.sh", {
    nexus-ip = var.nexus-ip,
    newrelic-license-key = var.newrelic-user-licence,
    newrelic-account-id = var.newrelic-acct-id,
    newrelic-region = var.newrelic-region

  }))
}

#Create AutoScaling Group
resource "aws_autoscaling_group" "prod-asg" {
  name                      = var.prod-asg-name
  desired_capacity          = 2
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 120
  health_check_type         = "EC2"
  force_delete              = true
  vpc_zone_identifier       = var.vpc-zone-identifier
  target_group_arns         = [var.tg-arn] 
  launch_template {
    id      = aws_launch_template.prod_lt.id
  }
  tag {
    key                 = "Name"
    value               = var.prod-asg-name
    propagate_at_launch = true
  }
}

#Create ASG Policy
resource "aws_autoscaling_policy" "prod-asg-policy" {
  name                   = var.prod-asg-policy-name
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.prod-asg.id
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}