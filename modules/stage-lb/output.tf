output "alb-stage-dns" {
  value = aws_lb.alb-stage.dns_name
}

output "alb-stage-arn" {
  value = aws_lb.alb-stage.arn
}

output "alb-stage-zoneid" {
  value = aws_lb.alb-stage.zone_id  
}

output "tg-stage-arn" {
  value = aws_lb_target_group.lb-tg-stage.arn
}