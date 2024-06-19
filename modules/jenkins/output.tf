output "jenkins_ip" {
  value = aws_instance.jenkins_server.private_ip
}
output "alb-jen-dns" {
  value = aws_lb.alb-jenkins.dns_name
}

output "alb-jen-arn" {
  value = aws_lb.alb-jenkins.arn
}

output "alb-jen-zoneid" {
  value = aws_lb.alb-jenkins.zone_id
}

output "tg-jen-arn" {
  value = aws_lb_target_group.jenlb-tg.arn
}