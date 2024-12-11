provider "aws" {
  region = "eu-west-2"
}

provider "aws" "assume_role" {
  region = "eu-west-2"
  assume_role {
    role_arn = var.role_arn # Use environment variable for Role ARN
  }
}

variable "role_arn" {
  description = "IAM Role ARN for assuming a role"
  type        = string
  default     = "${env.ROLE_ARN}" # Role ARN is provided as an environment variable
}

variable "vpc_name" {
  description = "Name for the VPC"
  type        = string
  default     = "main-vpc"
}

variable "igw_name" {
  description = "Name for the Internet Gateway"
  type        = string
  default     = "main-igw"
}

variable "public_subnet_name" {
  description = "Name prefix for public subnets"
  type        = string
  default     = "public-subnet"
}

variable "private_subnet_name" {
  description = "Name prefix for private subnets"
  type        = string
  default     = "private-subnet"
}

variable "public_route_table_name" {
  description = "Name for the public route table"
  type        = string
  default     = "public-route-table"
}

variable "private_route_table_name" {
  description = "Name for the private route table"
  type        = string
  default     = "private-route-table"
}

variable "nat_gateway_name" {
  description = "Name for the NAT Gateway"
  type        = string
  default     = "nat-gateway"
}

resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.igw_name
  }
}

resource "aws_subnet" "public" {
  count                   = 2 # Adjust for the number of availability zones
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.public_subnet_name}-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count             = 2 # Adjust for the number of availability zones
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 2)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.private_subnet_name}-${count.index}"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.public_route_table_name
  }
}

resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # NAT gateway is in the first public subnet

  tags = {
    Name = var.nat_gateway_name
  }
}

resource "aws_eip" "nat" {
  vpc = true
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.private_route_table_name
  }
}

resource "aws_route" "private" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

data "aws_availability_zones" "available" {}

output "vpc_id" {
  value = aws_vpc.main.id
  description = "The ID of the VPC."
}

output "vpc_name" {
  value = aws_vpc.main.tags["Name"]
  description = "The name of the VPC."
}

output "public_subnets" {
  value = aws_subnet.public[*].id
  description = "IDs of public subnets."
}

output "private_subnets" {
  value = aws_subnet.private[*].id
  description = "IDs of private subnets."
}

output "internet_gateway_id" {
  value = aws_internet_gateway.igw.id
  description = "The ID of the Internet Gateway."
}

output "nat_gateway_id" {
  value = aws_nat_gateway.nat.id
  description = "The ID of the NAT Gateway."
}




# export ROLE_ARN=arn:aws:iam::123456789012:role/example-role
# echo $ROLE_ARN
# terraform init
# terraform apply
