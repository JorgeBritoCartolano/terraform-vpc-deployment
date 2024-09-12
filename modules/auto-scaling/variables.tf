variable "vpc_id" {
  description = "The VPC ID where the bastion host will be deployed"
  type        = string
}

variable "bastion_host_sg_id" {
  description = "The bastion host security group"
  type        = string
}

variable "alb_sg_id" {
  description = "The ALB security group"
  type        = string
}

variable "ami_id" {
  description = "The AMI ID for the EC2 instances in the Auto Scaling Group"
  type        = string
}

variable "instance_type" {
  description = "The type of EC2 instance for the Auto Scaling Group"
  type        = string
}

variable "key_name" {
  description = "The name of the SSH key pair"
  type        = string
}

variable "min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
}

variable "max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
}

variable "desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
}

variable "ec2_http_port" {
  description = "HTTP port for the EC2 instances"
  type        = number
}

variable "ec2_ssh_port" {
  description = "SSH port for the EC2 instances"
  type        = number
}

variable "private_subnets_id" {
  description = "List of Auto Scaling Group private subnets IDs"
  type        = list(string)
}

variable "target_group_arn" {
  description = "ARN of the target group"
  type        = string
}