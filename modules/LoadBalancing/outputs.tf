output "alb_dns_name" {
  description = "value of the ALB DNS name"
  value       = aws_lb.public_alb.dns_name
}
output "alb_tg_name" {
  description = "value of the ALB target group name"
  value       = aws_lb_target_group.ecs_ec2_target_group.name
}
output "alb_tg_arn" {
  description = "value of the ALB target group ARN"
  value       = aws_lb_target_group.ecs_ec2_target_group.arn
}