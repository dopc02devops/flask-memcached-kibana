#####################
# Variables
#####################

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


# Export env variables for use in ec2.tf
# export TF_VAR_vpc_name="main-vpc"
# export TF_VAR_igw_name="main-igw"
# export TF_VAR_public_subnet_name="public-subnet"
# export TF_VAR_private_subnet_name="private-subnet"
# export TF_VAR_public_route_table_name="public-route-table"
# export TF_VAR_private_route_table_name="private-route-table"
