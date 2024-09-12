# Bastion Host Security Groups
resource "aws_security_group" "bastion_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr_block]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Bastion Security Group"
  }
}

# Bastion Host instance
resource "aws_instance" "bastion" {
  ami             = var.ami
  instance_type   = var.instance_type
  subnet_id       = var.public_subnet_id
  security_groups = [aws_security_group.bastion_sg.id]
  key_name        = var.key_name

  tags = {
    Name = "Bastion Host"
  }
}