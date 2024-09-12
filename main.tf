terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

module "vpc" {
  source               = "./modules/vpc"
  vpc_cidr_block       = var.vpc_cidr_block
  public_subnets_cidr  = var.public_subnets_cidr
  private_subnets_cidr = var.private_subnets_cidr
  availability_zones   = var.availability_zones
}

module "bastion_host" {
  source = "./modules/bastion-host"

  vpc_id                 = module.vpc.vpc_id
  allowed_ssh_cidr_block = var.allowed_ssh_cidr_block
  ami                    = var.bastion_ami
  instance_type          = var.bastion_instance_type
  public_subnet_id       = module.vpc.public_subnet_ids[0]
  key_name               = var.ssh_key_name_bastion_host
}

module "application_load_balancer" {
  source = "./modules/application-load-balancer"

  vpc_id            = module.vpc.vpc_id
  public_subnet_ids = module.vpc.public_subnet_ids
}

module "auto_scaling" {
  source = "./modules/auto-scaling"

  vpc_id             = module.vpc.vpc_id
  ami_id             = var.auto_scaling_ami_id
  bastion_host_sg_id = module.bastion_host.bastion_host_sg_id
  alb_sg_id          = module.application_load_balancer.alb_security_group_id
  private_subnets_id = module.vpc.private_subnet_ids
  instance_type      = var.auto_scaling_instance_type
  key_name           = var.auto_scaling_instance_key_name
  min_size           = var.auto_scaling_min_size
  max_size           = var.auto_scaling_max_size
  desired_capacity   = var.auto_scaling_desired_capacity
  ec2_http_port      = var.ec2_http_port
  ec2_ssh_port       = var.ec2_ssh_port
  target_group_arn   = module.application_load_balancer.target_group_arn
}

module "rds" {
  source = "./modules/rds"

  db_username             = var.db_username
  vpc_id                  = module.vpc.vpc_id
  bastion_host_sg_id      = module.bastion_host.bastion_host_sg_id
  asg_ec2_instances_sg_id = module.auto_scaling.asg_ec2_instances_sg_id
  private_subnet_ids      = [module.vpc.private_subnet_ids[2], module.vpc.private_subnet_ids[3]]
}

