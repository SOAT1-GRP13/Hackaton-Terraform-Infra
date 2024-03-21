
output "egress_all_id" {
  value       = aws_security_group.egress_all.id
}

output "ingress_api_id" {
  value       = aws_security_group.ingress_api.id
}

output "lb_target_group_ponto_arn" {
  description = "arn ponto target group"
  value       = aws_lb_target_group.ponto.arn
}

output "lb_target_group_relatorio_arn" {
  description = "arn relatorio target group"
  value       = aws_lb_target_group.relatorio.arn
}

output "lb_target_group_auth_arn" {
  description = "arn auth target group"
  value       = aws_lb_target_group.auth.arn
}

output "lb_target_group_rabbit_arn" {
  description = "arn rabbitmq target group"
  value       = aws_lb_target_group.rabbitmq.arn
}

output "lb_target_group_rabbit_management_arn" {
  description = "arn rabbitmqmanagement target group"
  value       = aws_lb_target_group.rabbitqmq_management.arn
}

output "listener_arn" {
  description = "arn of alb listener"
  value = aws_lb_listener.this.arn
}

output "dns_name" {
  description = "The DNS name of the load balancer"
  value       = try(aws_lb.this.dns_name, null)
}