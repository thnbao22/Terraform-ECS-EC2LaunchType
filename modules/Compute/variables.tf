variable "vpc_id" {
  type        = string
  description = "The ID of the VPC where the resources will be created."
}
variable "public_subnet_ids" {
  type        = list(string)
  description = "List of public subnet IDs to deploy the EC2 across multiple Availability Zones."
}
# variable "ec2_ssm_push_image_instance_profile_name" {
#   type        = string
#   description = "The ARN of the IAM instance profile to attach to the EC2 instance."
# }
variable "instance_count" {
  type        = number
  description = "The number of EC2 instances to create."
}
variable "ami_id" {
  type        = string
  description = "The AMI ID to use for the EC2 instance."
}
variable "instance_type" {
  type        = string
  description = "The EC2 instance type."
}
variable "user_data_file" {
  type        = string
  description = "The path to the user data file to use for the EC2 instance."
}
variable "naming_prefix" {
  type        = string
  description = "The prefix to use for naming resources."
}
variable "public_ssm_sg_id" {
  type        = string
  description = "The security group ID for the EC2 instance."
}