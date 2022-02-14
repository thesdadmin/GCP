data "template_file" "windows_startup" {
  template = file("${path.module}/restore.tpl")
  vars = {
    db_name       = var.db_name
    backup_bucket = var.bucket
    db_user       = var.db_user
    db_pass       = var.db_user_pass
  }
}

data "google_compute_image" "windows_image" {
  name    = var.windows_vm_image
  project = var.image_project
}

//create random number
resource "random_integer" "random_number" {
  max = 100
  min = 1
}

resource "google_compute_instance" "sql_server" {
  project      = var.project
  name         = "windows-2019-core-${var.db_name}-${random_integer.random_number.result}"
  machine_type = var.vm_size
  zone         = element(["us-central1-a", "us-central1-b", "us-central1-c", "us-central1-f"], random_integer.random_number.result % 4)
  tags         = ["ssh", "http", "rdp"]
  boot_disk {
    initialize_params {
      image = data.google_compute_image.windows_image.self_link
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
    windows-startup-script-cmd = "winrm quickconfig -quiet & net user /add ${var.db_user} ${var.db_user_pass} & net localgroup administrators ${var.db_user} /add & winrm set winrm/config/service/auth @{Basic=\"true\"} & curl -H \"Metadata-Flavor: Google\" \"http://metadata.google.internal/computeMetadata/v1/instance/attributes/another-script\" > c:/startup.ps1 & pwsh c:/startup.ps1"
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