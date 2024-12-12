####################
# Variables
####################

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default= "vpc-026934bcaa0b06df1"
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
  default= "ami-05c172c7f0d3aed00"
}

variable "public_subnet_id" {
  description = "Public Subnet ID"
  type        = string
  default= "subnet-049f47be570c47c25"
}

variable "private_subnet_ids" {
  description = "List of Private Subnet IDs"
  type        = list(string)
  default= [
             "subnet-0b0c271b7020daadc",
             "subnet-0421fe8cb80592ed8",
           ]

}