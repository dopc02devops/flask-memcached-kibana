provider "google" {
  project = "superb-gear-443409-t3"
  region  = "europe-west2"
  zone    = "europe-west2-a"
}

# Create virtual machine
resource "google_compute_instance" "e2_micro_instance" {
  name         = "ubuntu-e2-micro"
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
    ssh-keys = "kube_user:${file("/Users/elvisngwesse/.ssh/id_gcp_key.pub")}"
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

# Enable port 8081
resource "google_compute_firewall" "allow_ssh_8081" {
  name    = "allow-ssh"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["8081"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["ubuntu-test"]
}

# Variable
variable "create_firewall" {
  type    = bool
  default = false
}

# Out-put
output "instance_name_ip" {
  value = {
    name = google_compute_instance.e2_micro_instance.name
    ip   = google_compute_instance.e2_micro_instance.network_interface[0].access_config[0].nat_ip
  }
  description = "The name and public IP of the VM instance"
}




# ssh-keygen -t rsa -b 4096 -C "terraform" -f ~/.ssh/id_gcp_key
# ls -l ~/.ssh/id_gcp_key*
# ssh -i ~/.ssh/my_gcp_key dopc02devops@remote_ip to ssh into instance
# terraform init
# terraform plan
# terraform apply