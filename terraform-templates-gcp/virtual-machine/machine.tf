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
    ssh-keys             = "jenkins:${file("~/.ssh/id_kube_user_key.pub")}"
    metadata_startup_script = <<-EOT
      #!/bin/bash

      # Log file
      LOG_FILE="/var/log/startup-script.log"
      exec > >(tee -a $LOG_FILE) 2>&1

      echo "Starting startup script at $(date)..."

      # Update system packages
      echo "Updating system packages..."
      sudo apt-get update && sudo apt-get upgrade -y

      # Install Docker
      echo "Installing Docker..."
      if ! command -v docker > /dev/null; then
        sudo apt-get install -y docker.io
        echo "Docker installed successfully."
      else
        echo "Docker is already installed."
      fi

      # Create Docker group if it doesn't exist
      if ! getent group docker > /dev/null; then
        echo "Creating Docker group..."
        sudo groupadd docker
      else
        echo "Docker group already exists."
      fi

      # Add kube_user to the Docker group
      echo "Adding kube_user to the Docker group..."
      sudo usermod -aG docker kube_user

      # Restart Docker service to apply changes
      echo "Restarting Docker service..."
      sudo systemctl restart docker

      # Verify Docker installation and group membership
      echo "Docker version: $(docker --version)"
      echo "Groups for kube_user: $(groups kube_user)"

      echo "Startup script completed at $(date)."
    EOT
  }

  tags = ["web", "ubuntu"]
}

# Enable SSH
resource "google_compute_firewall" "ssh" {
#  count   = var.create_firewall ? 1 : 0
  name    = "allow-ssh"
  network = "default"
  provider = google
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["ubuntu"]
}

# Enable 8096
resource "google_compute_firewall" "http_8096" {
  name    = "allow-flask-app"
  network = "default"
  provider = google
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["8096"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["ubuntu"]
}

# Enable 8091
resource "google_compute_firewall" "http_8091" {
  name    = "allow-flask-apps"
  network = "default"
  provider = google
  allow {
    protocol = "icmp"
  }
  allow {
    protocol = "tcp"
    ports    = ["8091"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["ubuntu"]
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
