
terraform {
  backend "s3" {
    bucket = "terraform-qe33fdtgs86ltdhsiuyyu" # input bucket name
    key     = "vpc/terraform.tfstate"
    region  = "eu-west-2"
  }
}

# We are using backend to store data in s3 bucket to be retrieved by another
# terraform configuration.


# terraform init
# terraform plan
# terraform apply
# terraform destroy