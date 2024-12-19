
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
# Key Pair
########################################
resource "aws_key_pair" "ec2_key_pair" {
  key_name   = "my-key-pair"
  public_key = file("~/.ssh/id_rsa.pub") # Path to your public key
}

########################################
# EC2 Master Instance
########################################
resource "aws_instance" "master_instance" {
  ami             = var.ami_id
  instance_type   = "t2.micro"
  subnet_id       = data.terraform_remote_state.vpc.outputs.public_subnets[0]
  associate_public_ip_address = true
  key_name        = aws_key_pair.ec2_key_pair.key_name
  tags = {
    Name = "Master-Node"
  }
  vpc_security_group_ids = [aws_security_group.allow_ssh_http_https.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get upgrade -y
              apt-get install -y apache2
              systemctl enable apache2
              systemctl start apache2
              EOF
}

########################################
# EC2 Worker Instances 1
########################################
resource "aws_instance" "worker_instance_1" {
  ami             = var.ami_id
  instance_type   = "t2.micro"
  subnet_id       = data.terraform_remote_state.vpc.outputs.public_subnets[1]
  associate_public_ip_address = true
  key_name        = aws_key_pair.ec2_key_pair.key_name
  tags = {
    Name = "Worker-Node01"
  }
  vpc_security_group_ids = [aws_security_group.allow_ssh_http_https.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get upgrade -y
              apt-get install -y apache2
              systemctl enable apache2
              systemctl start apache2
              EOF
}

########################################
# EC2 Worker Instances 2
########################################
resource "aws_instance" "worker_instance_2" {
  ami             = var.ami_id
  instance_type   = "t2.micro"
  subnet_id       = data.terraform_remote_state.vpc.outputs.public_subnets[1]
  associate_public_ip_address = true
  key_name        = aws_key_pair.ec2_key_pair.key_name
  tags = {
    Name = "Worker-Node02"
  }
  vpc_security_group_ids = [aws_security_group.allow_ssh_http_https.id]

  user_data = <<-EOF
              #!/bin/bash
              apt-get update -y
              apt-get upgrade -y
              apt-get install -y apache2
              systemctl enable apache2
              systemctl start apache2
              EOF
}


########################################
# Security Groups
########################################

resource "aws_security_group" "allow_ssh_http_https" {
  name        = "allow_ssh_http_https"
  description = "Allow SSH, HTTP, and HTTPS inbound traffic"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # For kubernetes dashboard
  ingress {
    from_port   = 8091
    to_port     = 8091
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # For workers to join master
  ingress {
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


########################################
# Get data from backend
########################################

# Get the VPC ID from the remote state
data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "terraform-qe33fdtgs86ltdhsiuyyu"
    key    = "vpc/terraform.tfstate"
    region = "eu-west-2"
  }
}


########################################
# Output EC2 IP Addresses
########################################

output "master_instance_ip" {
  description = "Public IP of the public EC2 instance"
  value       = aws_instance.master_instance.public_ip
}

output "worker_instance_1_ip" {
  description = "Private IP of the first private EC2 instance"
  value       = aws_instance.worker_instance_1.public_ip
}

output "worker_instance_2_ip" {
  description = "Private IP of the second private EC2 instance"
  value       = aws_instance.worker_instance_2.public_ip
}



# export ROLE_ARN=arn:aws:iam::123456789012:role/example-role
# echo $ROLE_ARN
# terraform init
# terraform plan
# terraform apply
# terraform destroy