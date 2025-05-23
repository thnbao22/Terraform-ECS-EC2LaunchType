resource "aws_lb_target_group" "ecs_ec2_target_group" {
  name     = "${var.naming_prefix}-ec2-ecs-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "${var.naming_prefix}ecs-target-group"
  }
}

resource "aws_lb" "public_alb" {
  load_balancer_type = "application"
  name               = "${var.naming_prefix}-public-alb"
  internal           = false
  security_groups    = [var.alb_sg_id]
  subnets            = var.public_subnet_ids
  ip_address_type    = "ipv4"
}

resource "aws_lb_listener" "ecs_listener" {
  load_balancer_arn = aws_lb.public_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs_ec2_target_group.arn
  }
}