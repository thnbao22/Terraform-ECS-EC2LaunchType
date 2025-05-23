locals {
  endpoint_list = [
    "com.amazonaws.${var.region}.ecr.api",
    "com.amazonaws.${var.region}.ecr.dkr",
    "com.amazonaws.${var.region}.ecs-agent",
    "com.amazonaws.${var.region}.ecs-telemetry",
    "com.amazonaws.${var.region}.ecs"
  ]
}

resource "aws_vpc" "two_tier_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "${var.naming_prefix}-two-tier-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.two_tier_vpc.id
  tags = {
    "Name" = "${var.naming_prefix}-two-tier-igw"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "two_tier_public_subnet" {
  count                   = var.public_subnet_count
  vpc_id                  = aws_vpc.two_tier_vpc.id
  cidr_block              = "10.10.${count.index + 1}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    "Name" = "${var.naming_prefix}-public-subnet-${count.index + 1}"
  }
}
resource "aws_subnet" "two_tier_private_subnet" {
  count                   = var.private_subnet_count
  vpc_id                  = aws_vpc.two_tier_vpc.id
  cidr_block              = "10.10.${count.index + 3}.0/24"
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    "Name" = "${var.naming_prefix}-private-subnet-${count.index + 1}"
  }
}

resource "aws_route_table" "two_tier_public_rt" {
  vpc_id = aws_vpc.two_tier_vpc.id
  tags = {
    "Name" = "${var.naming_prefix}-public-route-table"
  }
}

resource "aws_route" "two_tier_public_subnet_rt" {
  route_table_id         = aws_route_table.two_tier_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "two_tier_public_subnet_rt_association" {
  route_table_id = aws_route_table.two_tier_public_rt.id
  count          = var.public_subnet_count
  subnet_id      = aws_subnet.two_tier_public_subnet[count.index].id
}

resource "aws_route_table" "two_tier_private_rt" {
  vpc_id = aws_vpc.two_tier_vpc.id
  tags = {
    "Name" = "${var.naming_prefix}-private-route-table"
  }
}

resource "aws_route_table_association" "two_tier_private_subnet_rt_association" {
  route_table_id = aws_route_table.two_tier_private_rt.id
  count          = var.private_subnet_count
  subnet_id      = aws_subnet.two_tier_private_subnet[count.index].id
}

resource "aws_security_group" "public_ssm_sg" {
  name        = "${var.naming_prefix}-public-ssm-sg"
  description = "SG for public EC2 instance"
  vpc_id      = aws_vpc.two_tier_vpc.id
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "public_alb_sg" {
  name        = "${var.naming_prefix}-ALB-SG"
  description = "Allow HTTP traffic"
  vpc_id      = aws_vpc.two_tier_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "private_asg_ec2_sg" {
  name        = "${var.naming_prefix}-private-asg-sg"
  description = "Allow all TCP traffic from ALB"
  vpc_id      = aws_vpc.two_tier_vpc.id
  ingress {
    from_port       = 0
    to_port         = 65535
    protocol        = "tcp"
    security_groups = [aws_security_group.public_alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "vpc_endpoint_sg" {
  name        = "${var.naming_prefix}-sg-vpc-endpoint"
  description = "Allow all TCP traffic from ASG EC2"
  vpc_id      = aws_vpc.two_tier_vpc.id
  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.private_asg_ec2_sg.id, aws_security_group.public_ssm_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_vpc_endpoint" "s3_gateway_endpoint" {
  vpc_id            = aws_vpc.two_tier_vpc.id
  service_name      = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids   = [aws_route_table.two_tier_private_rt.id]

  policy = <<Policy
{
  "Statement": [
    {
      "Sid": "Access-to-specific-bucket-only",
      "Principal": "*",
      "Effect": "Allow",
      "Action": [
        "s3:GetObject"
      ],
      "Resource": [
        "arn:aws:s3:::prod-${var.region}-starport-layer-bucket/*"
      ]
    }
  ]
}
Policy

  tags = {
    Name = "${var.naming_prefix}-s3-gateway-endpoint"
  }

}

resource "aws_vpc_endpoint" "container_vpc_endpont" {
  count               = length(local.endpoint_list)
  vpc_id              = aws_vpc.two_tier_vpc.id
  service_name        = local.endpoint_list[count.index]
  vpc_endpoint_type   = "Interface"
  subnet_ids          = aws_subnet.two_tier_private_subnet[*].id
  security_group_ids  = [aws_security_group.vpc_endpoint_sg.id]
  private_dns_enabled = true
  tags = {
    Name = "${var.naming_prefix}-${local.endpoint_list[count.index]}-vpc-endpoint"
  }
}