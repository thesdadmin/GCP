
resource "google_storage_bucket_object" "script" {
  name   = "ansible_apache.yml"
  source = "./ansible_apache.yml"
  bucket = data.google_storage_bucket.script.name
}

//create random number
resource "random_integer" "random_number" {
  max = 100
  min = 1
}

resource "google_compute_instance" "rhel_web" {
  project      = data.google_project.project.project_id
  name         = "rhel-web-${random_integer.random_number.result}"
  machine_type = "n1-standard-2"
  zone         = element(["us-central1-a", "us-central1-b", "us-central1-c", "us-central1-f"], random_integer.random_number.result % 4)
  tags         = ["public"]
  boot_disk {
    initialize_params {
      image = data.google_compute_image.rhel_image.self_link
    }
  }

  network_interface {
    subnetwork = data.google_compute_subnetwork.lab03.self_link
    //subnetwork = "projects/${data.google_project.project.project_id}/regions/us-central1/subnetworks/${var.subnet}"
  }

  metadata = {
    enable-oslogin     = "True"
    ssh-keys =<<EOT
   ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDY1tm/vi9Uf2W7bQG+ROQzgG5GHm22cy/N71oZ74PDpuQgaTsqEgfifSF/tgnDbIQPeE4dL6OkZKeLWiHeB9nx6H6zZx3hbSO7cWfR+qurn8vgDPid44mEafax2V1IucToZd+9PZY0gSu4ZggUjy8H+4BJKx0t0f0J757WzrLi7lDcSMkmvXLgnrnjvZ5B7Xrob8qAoK1/Ahwfq4e4edYQkaZCpRmuCFnxps0N+aoyTuKtfMIv8/ixzYB8gu7rMw0q9pyWSyXvVkXgnGq7VkEs/Yg4o/j/9QufxEUeQZXzX5Nnq9xYIvbgq9UF63sMYdcjZMWb0E0Z87ZDTDyGCSK6rs30fYARVYuVVpM5Jx5En7oXWnfew6PO2iuMtASzmTAZRtWPhHzDSaQqDFoszVUUYXOgz0cReuKdWJRWin/bYH22NUl7dktZCjLCE7oWUkaIi0A3uRx/xn+OcY1ivv5YvSNWbopyrCNp3uf24ycC6qWsfgEOGKJDlbQZDx9m8o0= robert@DESKTOP-7878DTA
    EOT
    startup-script =<<EOT
    #! /bin/bash
    sudo dnf -y update
    sudo dnf -y install python3-pip,lsof,vim
    sudo dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-8.noarch.rpm
    sudo dnf -y install ansible
    gsutil cp gs://lab-359-startup/ansible_apache.yml ~/ansible_apache.yml
    sudo ansible-galaxy collection install ansible.posix
    sudo ansible-playbook ~/ansible_apache.yml
    EOT
    
  }


  service_account {
    email  = google_service_account.sa.email
    scopes = ["cloud-platform"]
  }
}