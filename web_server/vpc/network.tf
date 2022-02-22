//Create a Router for outbound network access. 
resource "google_compute_router" "router" {
  name    = "coalfire-router"
  region  = module.vpc.subnets_regions[1]
  network = module.vpc.network_name
  project = data.google_project.project.project_id

  bgp {
    asn = 64514
  }
}

//Creates a GCP Cloud Nat instance to allow private VMs to reach the internet. 
resource "google_compute_router_nat" "nat" {
  name                               = "coalfire-router-nat"
  router                             = google_compute_router.router.name
  region                             = google_compute_router.router.region
  project                            = data.google_project.project.project_id
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}


