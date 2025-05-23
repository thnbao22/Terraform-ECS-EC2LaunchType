resource "aws_iam_role" "ec2_ssm_push_image_role" {
  name = "${var.naming_prefix}-ec2-ssm-push-image-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Retrieve the AmazonSSMManagedInstaceCore managed policy ARN
resource "aws_iam_role_policy_attachment" "ec2_ssm_policy" {
  role       = aws_iam_role.ec2_ssm_push_image_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Retrive the EC2InstanceProfileForImageBuilderECRContainerBuilds managed policy ARN
resource "aws_iam_role_policy_attachment" "ec2_image_builder_policy" {
  role       = aws_iam_role.ec2_ssm_push_image_role.name
  policy_arn = "arn:aws:iam::aws:policy/EC2InstanceProfileForImageBuilderECRContainerBuilds"
}

resource "aws_iam_instance_profile" "ec2_ssm_push_image_instance_profile" {
  name = "${var.naming_prefix}-ec2-ssm-push-image-instance-profile"
  role = aws_iam_role.ec2_ssm_push_image_role.name
}

resource "aws_instance" "ec2_instance" {
  count                       = var.instance_count
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = element(var.public_subnet_ids, count.index)
  iam_instance_profile        = aws_iam_instance_profile.ec2_ssm_push_image_instance_profile.name
  user_data                   = var.user_data_file
  associate_public_ip_address = true
  vpc_security_group_ids      = [var.public_ssm_sg_id]
  tags = {
    Name = "${var.naming_prefix}-ssm-ec2instance"
  }
}

