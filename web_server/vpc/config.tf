//Define the TF cloud provider and remote state location.

terraform {
  required_providers {
    lab = {
      source = "hashicorp/google"
    }
  }
  backend "gcs" {
    bucket = "terraform-state-lab3"
    prefix = "vpc"
  }
}

//Datasource the project id.
data "google_project" "project" {
  project_id = "lab-project-359"
}



