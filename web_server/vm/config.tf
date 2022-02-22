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

data "google_project" "project" {
  project_id = "lab-project-359"
}


data "google_compute_image" "rhel_image" {
  name    = "rhel-8-v20220126"
  project = "rhel-cloud"
}

data "google_storage_bucket" "script" {
  name = "lab-359-startup"
}

data "google_compute_subnetwork" "lab03" {
  project = data.google_project.project.project_id
  name    = "subnet-03"
  region  = "us-central1"
}



# data "terraform_remote_state" "vpc" {
#   backend = "gcs"
#   config = {
#     organization = "hashicorp/google"
#     bucket = "terraform-state-lab3"
#     prefix = "vpc"
#     //key = "default.tfstate"
#   }
# }