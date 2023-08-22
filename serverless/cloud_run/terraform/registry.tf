resource "google_artifact_registry_repository" "my-repo" {
  location      = "us-central1"
  repository_id = "lab-repository"
  description   = "Lab docker repository"
  format        = "DOCKER"

  docker_config {
    immutable_tags = true
  }
}