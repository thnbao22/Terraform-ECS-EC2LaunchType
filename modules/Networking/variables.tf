variable "vpc_cidr_block" {
  type        = string
  description = "CIDR block for the VPC"
}

variable "public_subnet_count" {
  type        = number
  description = "Number of public subnets to create"
}

variable "private_subnet_count" {
  type        = number
  description = "Number of private subnets to create"
}

variable "region" {
  type        = string
  description = "AWS region to deploy the resources"
}

variable "naming_prefix" {
  type        = string
  description = "Prefix for naming resources"
}