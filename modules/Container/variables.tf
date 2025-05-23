variable "vpc_id" {
  description = "The ID of the VPC where the resources will be created."
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs where the EC2 instances will be launched."
  type        = list(string)
}

variable "asg_ec2_security_group_id" {
  description = "The security group ID for the Auto Scaling Group."
  type        = string
}

variable "instance_type" {
  description = "The EC2 instance type."
  type        = string
}

variable "ami_id" {
  description = "The AMI ID to use for the EC2 instance."
  type        = string
}

variable "naming_prefix" {
  description = "The prefix to use for naming resources."
  type        = string
}

variable "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  type        = string
}
