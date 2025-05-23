output "vpc_id" {
  description = "value of the VPC ID"
  value       = aws_vpc.two_tier_vpc.id
}

output "public_subnet_ids" {
  description = "value of the public subnet IDs"
  value       = aws_subnet.two_tier_public_subnet[*].id
}

output "private_subnet_ids" {
  description = "value of the private subnet IDs"
  value       = aws_subnet.two_tier_private_subnet[*].id
}

output "alb_sg_id" {
  description = "value of the ALB security group ID"
  value       = aws_security_group.public_alb_sg.id
}

output "ec2_asg_sg_id" {
  description = "value of the EC2 Auto Scaling Group security group ID"
  value       = aws_security_group.private_asg_ec2_sg.id
}

output "public_ssm_sg_id" {
  description = "value of the public SSM security group ID"
  value       = aws_security_group.public_ssm_sg.id
}