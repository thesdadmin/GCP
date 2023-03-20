terraform {

  required_version = ">= 0.12.29"
}

provider "google" {
  project = var.project
  region  = var.region
}
