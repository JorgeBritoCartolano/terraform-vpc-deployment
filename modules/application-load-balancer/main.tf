# Load Balancer Security Group
resource "aws_security_group" "alb_sg" {
  vpc_id = var.vpc_id

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

  tags = {
    Name = "ALB Security Group"
  }
}

# Application Load Balancer
resource "aws_lb" "application_lb" {
  name               = "application-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids
  enable_deletion_protection = false

  enable_cross_zone_load_balancing = true
  enable_http2 = true

  tags = {
    Name = "Application Load Balancer"
  }
}

# Target Group
resource "aws_lb_target_group" "app_target_group" {
  name     = "inventory-target-group"
  port     = var.target_group_port
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    interval            = 30
    path                = "/products"
    port = var.target_group_port
    timeout             = 5
    healthy_threshold    = 2
    unhealthy_threshold  = 2
  }

  tags = {
    Name = "Inventory Target Group"
  }
}

# Listener Rule to forward requests to Target Group
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.application_lb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app_target_group.arn
  }
}