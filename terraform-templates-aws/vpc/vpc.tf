########################################
# Creates Network Address Translation (NAT)
# gateways for private subnets to access
# the internet securely
########################################
# resource "aws_nat_gateway" "nat" {
#   count        = 2
#   allocation_id = aws_eip.nat[count.index].id # Elastic IPs associated with the NAT gateways
#   subnet_id     = aws_subnet.public[count.index].id # Places NAT gateways in the public subnets

#   tags = {
#     Name = "nat-gateway-${count.index + 1}"
#   }
# }

########################################
# Allocates Elastic IPs for use with the
# NAT gateways
########################################
# resource "aws_eip" "nat" {
#   count = 2
#   domain = "vpc"
# }


########################################
# Fetches the list of available availability
# zones in the specified region
########################################
data "aws_availability_zones" "available" {
  state = "available"  # Optional: Filters to only return available zones
}

########################################
# Removes route configurations related to NAT gateway
########################################
resource "aws_route" "private" {
  count                    = length(aws_route_table.private)  # Adjust if you use count in the aws_route_table
  route_table_id           = aws_route_table.private[count.index].id  # Use count.index to refer to a specific route table instance
  destination_cidr_block   = "0.0.0.0/0"
  gateway_id               = aws_internet_gateway.igw.id  # Example with gateway_id, adjust as per your use case
}



########################################
# Creates the rest of the resources (no changes needed)
########################################
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

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

resource "random_string" "bucket_name" {
  length  = 16
  special = false
  upper   = false
}

resource "aws_s3_bucket" "backend_bucket" {
  bucket        = "terraform-${random_string.bucket_name.result}"
  force_destroy = true

  tags = {
    Name = "terraform-${random_string.bucket_name.result}"
  }
}

resource "aws_s3_bucket_policy" "public_policy" {
  bucket = aws_s3_bucket.backend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.backend_bucket.arn}/*"
      }
    ]
  })
  depends_on = [aws_s3_bucket.backend_bucket]
}

resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket = aws_s3_bucket.backend_bucket.id

  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = true

  depends_on = [aws_s3_bucket.backend_bucket]
}

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

output "private_route_table_ids" {
  value       = aws_route_table.private[*].id
  description = "The IDs of the private route tables."
}
