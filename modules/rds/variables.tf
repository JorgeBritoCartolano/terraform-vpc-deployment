variable "db_username" {
  description = "RDS database username"
  type = string
  default = "admin"
}

variable "vpc_id" {
  description = "The VPC ID where the bastion host will be deployed"
  type        = string
}

variable "bastion_host_sg_id" {
  description = "The bastion host security group"
  type        = string
}

variable "asg_ec2_instances_sg_id" {
  description = "The ASG EC2 instances security group"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the RDS instance"
  type        = list(string)
}