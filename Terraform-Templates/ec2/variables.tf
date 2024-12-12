####################
# Variables
####################

variable "vpc_id" {
  description = "VPC ID"
  type        = string
  default= "vpc-07a0925c8e88ca855"
}

variable "ami_id" {
  description = "AMI ID"
  type        = string
  default= "ami-05c172c7f0d3aed00"
}

variable "public_subnet_id" {
  description = "Public Subnet ID"
  type        = string
  default= "subnet-09d3589ce8cdd5897"
}

variable "private_subnet_ids" {
  description = "List of Private Subnet IDs"
  type        = list(string)
  default= [
             "subnet-040a1187353f16d75",
             "subnet-03fc913aedf19d22b",
           ]
}