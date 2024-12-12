
########################################
# Sets up the AWS provider for Terraform
# to interact with the AWS environment
########################################
provider "aws" {
  region = "eu-west-2"
}

provider "aws" {
  alias  = "default"
  region = "eu-west-2"
  assume_role {
    role_arn = env.role_arn
  }
}

########################################
# Creates a Virtual Private Cloud (VPC)
# with a specified CIDR block
########################################
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = var.vpc_name
  }
}

########################################
# Creates an Internet Gateway (IGW) to
# enable outbound internet access for
# resources within the VPC
########################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.igw_name
  }
}

########################################
# Creates public/private subnets in the
# VPC where instances have/do not internet
# access
########################################
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index)
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.public_subnet_name}-${count.index}"
  }
}

resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = aws_vpc.main.id
  cidr_block        = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 2)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "${var.private_subnet_name}-${count.index}"
  }
}

########################################
# Manages routing for public subnets to
# direct internet-bound traffic via the IGW
########################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.public_route_table_name
  }
}

resource "aws_route_table" "private" {
  count  = 2
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "private-route-table-${count.index + 1}"
  }
}
########################################
# Defines a route in the public route table
# to allow traffic to the internet.
########################################
resource "aws_route" "public" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private" {
  count                  = 2
  route_table_id         = aws_route_table.private[count.index].id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat[count.index].id
}

########################################
# Links the public route table to public
# subnets
########################################
resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}


########################################
# Creates Network Address Translation (NAT)
# gateways for private subnets to access
# the internet securely
########################################
resource "aws_nat_gateway" "nat" {
  count        = 2
  allocation_id = aws_eip.nat[count.index].id # Elastic IPs associated with the NAT gateways
  subnet_id     = aws_subnet.public[count.index].id # Places NAT gateways in the public subnets

  tags = {
    Name = "nat-gateway-${count.index + 1}"
  }
}

########################################
# Allocates Elastic IPs for use with the
# NAT gateways
########################################
resource "aws_eip" "nat" {
  count = 2
  domain = "vpc"
}

########################################
# Fetches the list of available availability
# zones in the specified region
########################################

data "aws_availability_zones" "available" {}

########################################
# Generate a random string for the
# bucket name
########################################
resource "random_string" "bucket_name" {
  length  = 16  # Adjust length as needed
  special = false  # Set to true if you want special characters
  upper   = false  # Set to true if you want uppercase characters
}

########################################
# S3 bucket
########################################
resource "aws_s3_bucket" "backend_bucket" {
  bucket        = "terraform-${random_string.bucket_name.result}"
  acl           = "private"
  force_destroy = true

  tags = {
    Name        = "terraform-${random_string.bucket_name.result}"
  }
}
#########################
# Outputs
#########################

output "bucket_name" {
  value = aws_s3_bucket.backend_bucket.bucket
}

output "vpc_id" {
  value       = aws_vpc.main.id
  description = "The ID of the VPC."
}

output "vpc_name" {
  value       = aws_vpc.main.tags["Name"]
  description = "The name of the VPC."
}

output "public_subnets" {
  value       = aws_subnet.public[*].id
  description = "IDs of public subnets."
}

output "private_subnets" {
  value       = aws_subnet.private[*].id
  description = "IDs of private subnets."
}

output "internet_gateway_id" {
  value       = aws_internet_gateway.igw.id
  description = "The ID of the Internet Gateway."
}

output "nat_gateway_id" {
  value       = aws_nat_gateway.nat[*].id
}

output "private_route_table_ids" {
  value       = aws_route_table.private[*].id
  description = "The IDs of the private route tables."
}


# export ROLE_ARN=arn:aws:iam::123456789012:role/example-role
# echo $ROLE_ARN
# terraform init
# terraform plan
# terraform apply
# terraform destroy