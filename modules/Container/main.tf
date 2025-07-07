resource "aws_iam_role" "ecs_instance_role_for_ec2_launch_type" {
  name = "${var.naming_prefix}-ecs-instance-ec2-launch-type-role"
  path = "/ecs/"
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

# Retrive the AmazonEC2ContainerServiceforEC2Role managed policy ARN
resource "aws_iam_role_policy_attachment" "ec2_container_service_role" {
  role       = aws_iam_role.ecs_instance_role_for_ec2_launch_type.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_instance_profile" "ec2_container_service_instance_profle" {
  name = "${var.naming_prefix}-ecs-instance-ec2-launch-type-instance-profile"
  role = aws_iam_role.ecs_instance_role_for_ec2_launch_type.name
}

resource "aws_ecr_repository" "ecr_repository" {
  name                 = "${var.naming_prefix}/nginx-custom-ecr-repo"
  image_tag_mutability = "IMMUTABLE"
  encryption_configuration {
    encryption_type = "AES256"
  }
  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "aws_ecs_cluster" "nginx_ecs_cluster" {
  name = "${var.naming_prefix}-${var.ecs_cluster_name}"
}

resource "aws_launch_template" "nginx_ecs_cluster_launch_template" {
  name                   = "${var.naming_prefix}-nginx-custom-app-launch-template"
  image_id               = var.ami_id
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.asg_ec2_security_group_id]

  user_data = base64encode(<<EOF
#!/bin/bash
echo ECS_CLUSTER=${aws_ecs_cluster.nginx_ecs_cluster.name} >> /etc/ecs/ecs.config
echo ECS_LOGLEVEL=debug >> /etc/ecs/ecs.config
echo ECS_ENABLE_TASK_IAM_ROLE=true >> /etc/ecs/ecs.config
EOF
  ) 

  # user_data = base64encode(<<EOT
  #   #!/bin/bash
  #   cat <<EOF > /etc/ecs/ecs.config
  #   ECS_CLUSTER=${aws_ecs_cluster.nginx_ecs_cluster.name}
  #   ECS_LOGLEVEL=debug
  #   ECS_ENABLE_TASK_IAM_ROLE=true
  #   EOF
  # EOT
  # )

  iam_instance_profile {
    # name = aws_iam_instance_profile.ec2_container_service_instance_profle.name
    arn = aws_iam_instance_profile.ec2_container_service_instance_profle.arn
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "nginx_ecs_cluster_asg" {
  name                      = "${var.naming_prefix}-nginx-custom-app-asg"
  min_size                  = 2
  max_size                  = 4
  desired_capacity          = 2
  vpc_zone_identifier       = var.private_subnet_ids
  health_check_type         = "EC2"
  health_check_grace_period = 0

  enabled_metrics = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances"
  ]

  launch_template {
    id      = aws_launch_template.nginx_ecs_cluster_launch_template.id
    version = "$Latest"
  }

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "${var.naming_prefix}-nginx-custom-app-asg"
    propagate_at_launch = true
  }
  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }
}

resource "aws_ecs_capacity_provider" "ecs_capacity_provider" {
  name = "${var.naming_prefix}-nginx-custom-app-capacity-provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.nginx_ecs_cluster_asg.arn
    managed_termination_protection = "DISABLED"
  }
}

resource "aws_ecs_cluster_capacity_providers" "ecs_cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.nginx_ecs_cluster.name
  capacity_providers = [
    aws_ecs_capacity_provider.ecs_capacity_provider.name
  ]
}