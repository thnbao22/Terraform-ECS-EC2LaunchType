data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ami" "most_recent_amazon_linux_2023" {
  most_recent = true

  owners = ["amazon"]

  filter {
    name = "name"
    # values = ["al2023-ami-*-x86_64"]
    values = ["al2023-ami-2023.*-kernel-6.1-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}