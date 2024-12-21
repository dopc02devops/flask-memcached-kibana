
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
  public_key = file("~/.ssh/id_kube_user_key.pub")
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
  vpc_security_group_ids = [aws_security_group.nfs_security_group.id, aws_security_group.http_Kubernetes_sg.id]

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
  vpc_security_group_ids = [aws_security_group.nfs_security_group.id, aws_security_group.http_Kubernetes_sg.id]

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
  vpc_security_group_ids = [aws_security_group.nfs_security_group.id, aws_security_group.http_Kubernetes_sg.id]

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

# nfs security-group
resource "aws_security_group" "nfs_security_group" {
  name        = "nfs-security-group"
  description = "Security group for NFS server access"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # Inbound Rules
  ingress {
    from_port   = 111
    to_port     = 111
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 32768
    to_port     = 32768
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 44182
    to_port     = 44182
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 54508
    to_port     = 54508
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 111
    to_port     = 111
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 2049
    to_port     = 2049
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 32768
    to_port     = 32768
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 32770
    to_port     = 32800
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound Rules
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "http_Kubernetes_sg" {
  name        = "allow_ssh_http_https"
  description = "Allow SSH, HTTP, HTTPS, Kubernetes, and NFS inbound traffic"
  vpc_id      = data.terraform_remote_state.vpc.outputs.vpc_id

  # Allow SSH
  ingress {
    description = "Allow SSH traffic"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP
  ingress {
    description = "Allow HTTP traffic"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTPS
  ingress {
    description = "Allow HTTPS traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow ICMP
  ingress {
    description = "Allow ICMP traffic"
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # flask app port
  ingress {
    description = "Allow flask app traffic"
    from_port   = 8095
    to_port     = 8095
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Kubernetes Dashboard
  ingress {
    description = "Allow Kubernetes Dashboard traffic"
    from_port   = 8091
    to_port     = 8091
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Kubernetes Worker to Join Master
  ingress {
    description = "Allow Kubernetes Worker to join Master traffic"
    from_port   = 6443
    to_port     = 6443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow NFS Traffic
  ingress {
    description = "Allow NFS traffic"
    from_port   = 2049
    to_port     = 2049
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow All Outbound Traffic
  egress {
    description = "Allow all outbound traffic"
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