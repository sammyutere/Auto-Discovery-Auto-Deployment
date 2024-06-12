# Create Launch Template
resource "aws_launch_template" "stage_lt" {
  image_id               = var.ami
  instance_type          = "t2.medium"
  vpc_security_group_ids = [var.asg-sg]
  key_name               = var.pub-key
  user_data = templatefile("./docker-script.sh", {
    nexus-ip = var.nexus-ip,
    newrelic-license-key = var.newrelic-user-licence,
    acct-id = var.newrelic-acct-id,
    nexus-username = var.nexus-username,
    nexus-password = var.nexus-password,
    repository = var.repository,
    image-name = var.image-name,
    container-name = var.container-name,
    host-port = var.host-port,
    container-port = var.container-port
  })
}

#Create AutoScaling Group
resource "aws_autoscaling_group" "stage-asg" {
  name                      = "stage-asg"
  desired_capacity          = 2
  max_size                  = 5
  min_size                  = 1
  health_check_grace_period = 120
  health_check_type         = "EC2"
  force_delete              = true
  vpc_zone_identifier       = var.vpc-zone-identifier
  target_group_arns         = var.tg-arn
  launch_template {
    id      = aws_launch_template.stage_lt.id
    version = "$Latest"
  }
  tag {
    key                 = "Name"
    value               = "stage-instance"
    propagate_at_launch = true
  }
}

#Create ASG Policy
resource "aws_autoscaling_policy" "stage-asg-policy" {
  name                   = var.stage-asg-policy-name
  adjustment_type        = "ChangeInCapacity"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.stage-asg.id
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }
}