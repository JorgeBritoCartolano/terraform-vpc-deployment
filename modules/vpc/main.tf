# VPC
resource "aws_vpc" "inventory-vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "Inventory VPC"
  }
}

# Internet Gateway 
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.inventory-vpc.id
  tags = {
    Name = "Inventory IGW"
  }
}

# Public subnets
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.inventory-vpc.id
  cidr_block              = element(var.public_subnets_cidr, count.index)
  availability_zone       = element(var.availability_zones, count.index)
  map_public_ip_on_launch = true
  tags = {
    Name = "Public Subnet ${count.index + 1}"
  }
}

# Private subnets
resource "aws_subnet" "private" {
  count             = 4
  vpc_id            = aws_vpc.inventory-vpc.id
  cidr_block        = element(var.private_subnets_cidr, count.index)
  availability_zone = element(var.availability_zones, count.index % 2)
  tags = {
    Name = "Private Subnet ${count.index + 1}"
  }
}

# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.inventory-vpc.id
  tags = {
    Name = "Public Route Table"
  }
}

# Public subnets route table association
resource "aws_route_table_association" "public_subnets" {
  count          = 2
  subnet_id      = element(aws_subnet.public[*].id, count.index)
  route_table_id = aws_route_table.public.id
}

# Public route table rules
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Elastic IP for NAT Gateway 
resource "aws_eip" "nat" {
  domain = "vpc"
  tags = {
    Name = "NAT EIP"
  }
}

# NAT Gateway in a public subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id
  tags = {
    Name = "Main NAT Gateway"
  }
}

# Route table for private subntes
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.inventory-vpc.id
  tags = {
    Name = "Private Route Table"
  }
}

# Route from private subnets to NAT Gateway
resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Association of private route table with private subnets
resource "aws_route_table_association" "private_subnets" {
  count          = 4
  subnet_id      = element(aws_subnet.private[*].id, count.index)
  route_table_id = aws_route_table.private.id
}