
resource "google_storage_bucket" "auto-expire" {
  name          = "auto-expiring-bucket-lab"
  location      = "US"
  force_destroy = true

  lifecycle_rule {
    condition {
      test =  var.apply_lifecycle_rule ? "age":"version"
      age = 45
      matches_prefix = ["*/DIFF/*.bak","*/FULL/*.bak"]
    }
    action {
      type = "Delete"
    }
    
  }

}