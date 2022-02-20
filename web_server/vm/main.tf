data "google_compute_image" "rhel_image" {
  name    = "rhel-8-v20220126"
  family  = "rhel-8" 
  project = "rhel-cloud"
}

//create random number
resource "random_integer" "random_number" {
  max = 100
  min = 1
}

resource "google_compute_instance" "sql_server" {
  project      = var.project
  name         = "rhel-${var.db_name}-${random_integer.random_number.result}"
  machine_type = var.vm_size
  zone         = element(["us-central1-a", "us-central1-b", "us-central1-c", "us-central1-f"], random_integer.random_number.result % 4)
  tags         = ["ssh", "http", "rdp"]
  boot_disk {
    initialize_params {
      image = data.google_compute_image.rhel_image.self_link
    }
  }

  // Local SSD disk
  scratch_disk {
    interface = "SCSI"
  }

  network_interface {
    subnetwork = "projects/${var.vpc_project}/regions/${var.region}/subnetworks/${var.subnet}"
  }

  metadata = {
    enable-oslogin             = "True"
    startup-script-ps1 = <<EOT
    ansible-playbook -i inventory playbook.yml
    EOT
    //    windows-startup-script-ps1 = data.template_file.windows_startup.rendered
    another-script = data.template_file.windows_startup.rendered
  }

  service_account {
    //    email  = var.service_account
    scopes = ["cloud-platform"]
  }
}

//add random password
resource "random_password" "random_password" {
  length = 12
}

output "sql_server_ip" {
  value = google_compute_instance.sql_server.network_interface[0].network_ip
}

output "reset_password" {
  value = "gcloud beta compute reset-windows-password ${google_compute_instance.sql_server.name}"
}

output "rdp_proxy" {
  value = "gcloud compute start-iap-tunnel ${google_compute_instance.sql_server.name} 3389 --local-host-port=localhost:3389"
}

output "logs" {
  value = "gcloud compute instances get-serial-port-output ${google_compute_instance.sql_server.name}"
}

output "password" {
//  value = random_password.random_password.result
  value = var.db_user_pass
}