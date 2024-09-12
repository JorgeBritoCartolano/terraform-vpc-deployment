variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs"
  type        = list(string)
}

variable "target_group_port" {
  description = "Port for the target group"
  type        = number
  default     = 8080
}