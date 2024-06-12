output "Prod-ASG-id" {
  value = aws_autoscaling_group.prod-asg.id
}

output "Prod-ASG-name" {
  value = aws_autoscaling_group.prod-asg.name
}

output "Prod-LT-id" {
  value = aws_launch_template.prod_lt.image_id
}