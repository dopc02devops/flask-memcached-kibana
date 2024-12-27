provider "google" {
  project = "superb-gear-443409-t3"
  region  = "europe-west2"
  zone    = "europe-west2-a"
}

# Create virtual machine
resource "google_compute_instance" "e2_micro_instance" {
  name         = "build-machine"
  machine_type = "e2-micro"
  zone         = "europe-west2-a"

  boot_disk {
    initialize_params {
      image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2004-lts"
    }
  }

  network_interface {
    network = "default"
    access_config {
    }
  }

  metadata = {
    # Create user and copy ssh key
    ssh-keys             = "kube_user:${file("~/.ssh/id_kube_user_key.pub")}"
    metadata_startup_script = <<-EOT
      #!/bin/bash
      # Update system packages
      sudo apt-get update

      # Install Docker
      sudo apt-get install -y docker.io

      # Create Docker group
      if ! getent group docker; then
        sudo groupadd docker
      fi

      # Add kube_user to Docker group
      sudo usermod -aG docker kube_user

      # Restart Docker to apply group changes
      sudo systemctl restart docker

      # Confirm Docker is installed and group is set up
      docker --version
      groups kube_user
    EOT
  }

  tags = ["web", "ubuntu-test"]
}


# Enable ssh
resource "google_compute_firewall" "allow_ssh" {
  count   = var.create_firewall ? 1 : 0
  name    = "allow-ssh"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["ubuntu-test"]
}


# Enable port 8091
resource "google_compute_firewall" "allow_8091" {
  name    = "allow-8091"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["8091"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["ubuntu-test"]
}


# Variable
variable "create_firewall" {
  type    = bool
  default = false
}

# Output
output "instance_name_ip" {
  value = {
    name = google_compute_instance.e2_micro_instance.name
    ip   = google_compute_instance.e2_micro_instance.network_interface[0].access_config[0].nat_ip
  }
  description = "The name and public IP of the VM instance"
}

# Instructions:
# 1. ssh-keygen -t rsa -b 4096 -C "terraform" -f ~/.ssh/id_gcp_key
# 2. ls -l ~/.ssh/id_gcp_key*
# 3. ssh -i ~/.ssh/id_gcp_key kube_user@remote_ip to ssh into instance
# 4. terraform init
# 5. terraform plan
# 6. terraform apply
