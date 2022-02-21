resource "google_project_iam_custom_role" "storage" {
  role_id     = "bucket.viewer"
  title       = "Custom Bucket Viewer Role"
  description = "Allows Viewer rights to Buckets"
  project     = data.google_project.project.project_id
  permissions = ["storage.buckets.get","storage.buckets.list"]
}

resource "google_service_account" "sa" {
  account_id   = "lab-compute-sa"
  display_name = "A service account for LAB instances"
  project      = data.google_project.project.project_id
}

resource "google_project_iam_member" "sa_compute_inst" {
  project = data.google_project.project.project_id
  role    = "roles/compute.instanceAdmin.v1"
  member  = "serviceAccount:${google_service_account.sa.email}"
}


resource "google_project_iam_member" "sa_compute_storage" {
  project = data.google_project.project.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.sa.email}"
}

resource "google_project_iam_member" "sa_compute_storage_2" {
  project = data.google_project.project.project_id
  role    = "${google_project_iam_custom_role.storage.id}"
  member  = "serviceAccount:${google_service_account.sa.email}"
}