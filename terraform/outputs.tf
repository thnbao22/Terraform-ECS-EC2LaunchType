output "alb_dns_name" {
  value       = module.LoadBalancer.alb_dns_name
  description = "value of the ALB DNS name"
}