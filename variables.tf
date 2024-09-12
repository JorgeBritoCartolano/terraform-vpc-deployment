variable "vpc_cidr_block" {
  description = "The CIDR block for the VPC"
  default     = "10.0.0.0/16"
}

variable "public_subnets_cidr" {
  description = "List of CIDR blocks for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnets_cidr" {
  description = "List of CIDR blocks for private subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
}

variable "availability_zones" {
  description = "List of availability zones"
  default     = ["eu-west-3a", "eu-west-3b"]
}

variable "allowed_ssh_cidr_block" {
  description = "CIDR block allowed to access the bastion host via SSH"
  type        = string
}

variable "bastion_ami" {
  description = "The AMI ID for the bastion host"
  type        = string
}

variable "bastion_instance_type" {
  description = "The instance type for the bastion host"
  default     = "t2.micro"
}

variable "ssh_key_name_bastion_host" {
  description = "The name of the SSH key pair to access the bastion host"
  type        = string
}

variable "auto_scaling_ami_id" {
  description = "The AMI ID for the EC2 instances in the Auto Scaling Group"
  type        = string
}

variable "auto_scaling_instance_type" {
  description = "The type of EC2 instance for the Auto Scaling Group"
  type        = string
  default     = "t2.micro"
}

variable "auto_scaling_instance_key_name" {
  description = "The name of the SSH key pair"
  type        = string
}

variable "auto_scaling_min_size" {
  description = "Minimum size of the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "auto_scaling_max_size" {
  description = "Maximum size of the Auto Scaling Group"
  type        = number
  default     = 4
}

variable "auto_scaling_desired_capacity" {
  description = "Desired capacity of the Auto Scaling Group"
  type        = number
  default     = 2
}

variable "ec2_http_port" {
  description = "HTTP port for the EC2 instances"
  type        = number
  default     = 8080
}

variable "ec2_ssh_port" {
  description = "SSH port for the EC2 instances"
  type        = number
  default     = 22
}

variable "target_group_port" {
  description = "Port for the target group"
  type        = number
  default     = 8080
}

variable "db_username" {
  description = "RDS database username"
  type        = string
  default     = "admin"
}