//Define TF Provider and store state in GCS
terraform {
  required_providers {
    gcs = {
      source = "hashicorp/google"
    }
  }
  backend "gcs" {
    bucket = "terraform-state-lab3"
    prefix = "vm"
  }
}

//datasource project
data "google_project" "project" {
  project_id = "lab-project-359"
}

//datasource rhel image
data "google_compute_image" "rhel_image" {
  name    = "rhel-8-v20220126"
  project = "rhel-cloud"
}

//datasource bucket for script
data "google_storage_bucket" "script" {
  name = "lab-359-startup"
}

//datasource subnet
data "google_compute_subnetwork" "lab03" {
  project = data.google_project.project.project_id
  name    = "subnet-03"
  region  = "us-central1"
}
