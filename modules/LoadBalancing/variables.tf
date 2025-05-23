variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the resources will be created."
}

variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs to deploy the ALB across multiple Availability Zones."

  validation {
    condition     = length(var.public_subnet_ids) >= 2
    error_message = "At least 2 public subnet IDs are required to deploy an ALB across multiple Availability Zones."
  }
}

variable "alb_sg_id" {
  type        = string
  description = "The security group ID for the ALB."
}

variable "naming_prefix" {
  type        = string
  description = "The prefix to use for naming resources."
}
