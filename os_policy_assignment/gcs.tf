resource "google_storage_bucket" "auto-expire" {
  count =  var.apply_lifecycle_rule == "age" ? 1:0
  name          = "auto-expiring-bucket-lab"
  location      = "US"
  force_destroy = true

  lifecycle_rule {
    condition {
      age = 45
      matches_prefix = ["*/DIFF/*.bak","*/FULL/*.bak"]
    }
    action {
      type = "Delete"
    }
    
  }

}

resource "google_storage_bucket" "auto-expire" {
  count =  var.apply_lifecycle_rule == "version" ? 1:0  
  name          = "auto-expiring-bucket-lab"
  location      = "US"
  force_destroy = true

  lifecycle_rule {
    condition {
      
      age = 45
      matches_prefix = ["*/DIFF/*.bak","*/FULL/*.bak"]
    }
    action {
      type = "Delete"
    }
    
  }

}