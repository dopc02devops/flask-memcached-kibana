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

# Data block to retrieve running EC2 instances
data "aws_instances" "running_instances" {
  filter {
    name   = "instance-state-name"
    values = ["running"]
  }
}

# Stop the running EC2 instances
resource "aws_instance" "stopped_instances" {
  for_each = { for id, instance in data.aws_instances.running_instances.ids : id => instance }

  instance_id = each.value

  stop {
    force = true
  }
}

# Output the stopped instances
output "stopped_instance_ids" {
  value = [for id in aws_instance.stopped_instances : id.id]
  description = "List of stopped EC2 instance IDs"
}
