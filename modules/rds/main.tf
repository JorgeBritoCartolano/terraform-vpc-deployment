resource "random_password" "db_password" {
  length           = 16
  special          = true
  override_special = "!#$%&()*+,-.:;<=>?[]^_{|}~"
}

resource "aws_secretsmanager_secret" "db_credentials" {
  name        = "rds_db_credentials"
  description = "Credentials for the RDS database"
}

resource "aws_secretsmanager_secret_version" "db_credentials_value" {
  secret_id     = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username,
    password = random_password.db_password.result
    engine = aws_db_instance.inventory_rds.engine
    host = element(split(":", aws_db_instance.inventory_rds.endpoint), 0)
    port = aws_db_instance.inventory_rds.port
  })
  depends_on = [aws_db_instance.inventory_rds]
}

resource "aws_security_group" "db_sg" {
  vpc_id = var.vpc_id

  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [var.asg_ec2_instances_sg_id]
  }

    ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [var.bastion_host_sg_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DB Security Group"
  }
}

resource "aws_db_subnet_group" "db_subnet_group" {
  name       = "db-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "DB Subnet Group"
  }
}

resource "aws_db_instance" "inventory_rds" {
  identifier         = "inventory-db"
  engine             = "mysql"
  instance_class     = "db.t3.micro"
  allocated_storage  = 20
  db_subnet_group_name = aws_db_subnet_group.db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  multi_az           = false
  engine_version     = "8.0"
  publicly_accessible = false
  storage_encrypted  = true

  username           = var.db_username
  password           = random_password.db_password.result

  skip_final_snapshot = true
  apply_immediately   = true

  tags = {
    Name = "Inventory RDS Database"
  }
}