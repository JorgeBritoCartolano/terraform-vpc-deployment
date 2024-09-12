# EC2 instance role
resource "aws_iam_role" "ec2_role" {
  name = "InventoryEC2Role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# EC2 role policy
resource "aws_iam_role_policy_attachment" "s3_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
}

# EC2 role policy
resource "aws_iam_role_policy_attachment" "secrets_manager_policy" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

# Instance profile
resource "aws_iam_instance_profile" "instance_profile" {
  name = "inventory_app_ec2_instance_profile"
  role = aws_iam_role.ec2_role.name
}

# EC2 Security Groups
resource "aws_security_group" "ec2_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port       = var.ec2_http_port              
    to_port         = var.ec2_http_port              
    protocol        = "tcp"
    security_groups = [var.alb_sg_id]
  }

  ingress {
    from_port       = var.ec2_ssh_port               
    to_port         = var.ec2_ssh_port               
    protocol        = "tcp"
    security_groups = [var.bastion_host_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Inventory EC2 Security Group"
  }
}

# Launch Template 
resource "aws_launch_template" "app_template" {
  name_prefix   = "InventoryLaunchTemplate"
  image_id      = var.ami_id                        
  instance_type = var.instance_type                 
  key_name      = var.key_name                      
  iam_instance_profile {
    name = aws_iam_instance_profile.instance_profile.name
  }
  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ec2_sg.id]
  }
  tags = {
    Name = "Inventory Instance"
  }
}

# Auto Scaling Group
resource "aws_autoscaling_group" "inventory_asg" {
  desired_capacity    = var.desired_capacity       
  max_size            = var.max_size               
  min_size            = var.min_size               
  vpc_zone_identifier = [var.private_subnets_id[0], var.private_subnets_id[1]]

  launch_template {
    id      = aws_launch_template.app_template.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Inventory ASG instance"
    propagate_at_launch = true
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300

  target_group_arns = [var.target_group_arn]
}