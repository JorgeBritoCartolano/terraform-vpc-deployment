variable "vpc_id" {
  description = "The VPC ID where the bastion host will be deployed"
  type        = string
}

variable "allowed_ssh_cidr_block" {
  description = "CIDR block allowed to access the bastion host via SSH"
  type        = string
}

variable "ami" {
  description = "The AMI ID for the bastion host"
  type        = string
}

variable "instance_type" {
  description = "The instance type for the bastion host"
  type        = string
}

variable "public_subnet_id" {
  description = "The subnet ID where the bastion host will be deployed"
  type        = string
}

variable "key_name" {
  description = "The name of the SSH key pair to access the bastion host"
  type        = string
}