provider "aws" {
  region = "eu-west-2"
}

provider "aws" {
  alias  = "default"
  region = "eu-west-2"
  assume_role {
    role_arn = var.role_arn
  }
}

data "aws_instances" "stopped" {
  instance_state_names = ["stopped"]
}

# Start the stopped instances
resource "null_resource" "start_stopped_instances" {
  for_each = toset(data.aws_instances.stopped.ids)

  provisioner "local-exec" {
    command = "aws ec2 start-instances --instance-ids ${each.key}"
  }
}

output "stopped_instances" {
value = data.aws_instances.stopped.ids
}
