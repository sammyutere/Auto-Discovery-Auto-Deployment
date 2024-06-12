output "alb-prod-dns" {
  value = aws_lb.alb-prod.dns_name
}

output "alb-prod-arn" {
  value = aws_lb.alb-prod.arn
}

output "alb-prod-zoneid" {
  value = aws_lb.alb-prod.zone_id  
}

output "tg-prod-arn" {
  value = aws_lb_target_group.lb-tg-prod.arn
}