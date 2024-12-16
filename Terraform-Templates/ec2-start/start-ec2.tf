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

# Data block to retrieve stopped EC2 instances
data "aws_instances" "stopped_instances" {
  filter {
    name   = "instance-state-name"
    values = ["stopped"]
  }
}

# Start the stopped EC2 instances
resource "aws_instance" "started_instances" {
  for_each = { for id, instance in data.aws_instances.stopped_instances.ids : id => instance }

  instance_id = each.value

  start {
    # Force starts the instances (though usually not necessary)
    force = true
  }
}

# Output the started instances
output "started_instance_ids" {
  value       = [for id in aws_instance.started_instances : id.id]
  description = "List of started EC2 instance IDs"
}
