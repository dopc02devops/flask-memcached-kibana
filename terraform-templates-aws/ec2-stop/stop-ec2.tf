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

# Stop the running EC2 instances using local-exec
resource "null_resource" "stop_instances" {
  for_each = toset(data.aws_instances.running_instances.ids)

  provisioner "local-exec" {
    command = "aws ec2 stop-instances --instance-ids ${each.value}"
  }
}

# Output the stopped instances
output "stopped_instance_ids" {
  value = [for id in null_resource.stop_instances : id.id]
  description = "List of stopped EC2 instance IDs"
}