
//Module from the Terraform registry. The Module is maintained by Google. 
// https://registry.terraform.io/modules/terraform-google-modules/network/google/latest
module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 4.0"

  project_id = data.google_project.project.project_id

  //Define a VPC network 
  network_name = "coalfire"
  routing_mode = "GLOBAL"
  mtu          = 1460

  //define VPC subnets. 
  subnets = [
    {
      subnet_name           = "subnet-01"
      subnet_ip             = "10.10.10.0/24"
      subnet_region         = "us-central1"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Public Subnet-1"
    },
    {
      subnet_name           = "subnet-02"
      subnet_ip             = "10.10.20.0/24"
      subnet_region         = "us-central1"
      subnet_private_access = "true"
      subnet_flow_logs      = "true"
      description           = "Public Subnet-2"
    },
    {
      subnet_name               = "subnet-03"
      subnet_ip                 = "10.10.30.0/24"
      subnet_region             = "us-central1"
      subnet_flow_logs          = "true"
      subnet_flow_logs_interval = "INTERVAL_10_MIN"
      subnet_flow_logs_sampling = 0.7
      subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
      description               = "Private Subnet-1"
    },
    {
      subnet_name               = "subnet-04"
      subnet_ip                 = "10.10.40.0/24"
      subnet_region             = "us-central1"
      subnet_flow_logs          = "true"
      subnet_flow_logs_interval = "INTERVAL_10_MIN"
      subnet_flow_logs_sampling = 0.7
      subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
      description               = "Private Subnet-2"
    }
  ]

  //define VPC Routes
  routes = [
    {
      name              = "egress-internet"
      description       = "route through IGW to access internet"
      destination_range = "0.0.0.0/0"
      tags              = "egress-inet"
      next_hop_internet = "true"
    }

  ]

  //Define VPC Firewall rules
  firewall_rules = [
    {
      //Allow IAP-Tunnel from the GCP Service to the compute instances for remote management. 
      name                    = "allow-iap"
      description             = "Allow IAP access to VM"
      direction               = "INGRESS"
      priority                = 10
      ranges                  = ["35.235.240.0/20"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = ["public"]
      target_service_accounts = null
      allow = [{
        protocol = "tcp"
        ports    = ["22"]
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },

    {
      //Allow inbound webtraffic to reach Network interfaces with the desginated "public" tag
      name                    = "allow-http"
      description             = "All web traffic"
      direction               = "INGRESS"
      priority                = 20
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = ["public"]
      target_service_accounts = null
      allow = [{
        protocol = "tcp"
        ports = [
          "80",
          "443"
        ]
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    {
      //Allow outbound internet access for TCP traffic. 
      name                    = "outbound-tcp"
      description             = "Allow Egress"
      direction               = "EGRESS"
      priority                = 200
      destination_ranges      = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow = [{
        protocol = "tcp",
        ports    = ["1-1023"]
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    },
    {
      //Allow outbound UDP traffic. 
      name                    = "outbound-udp"
      description             = "Egress UDP"
      priority                = 210
      direction               = "EGRESS"
      ranges                  = ["0.0.0.0/0"]
      source_tags             = null
      source_service_accounts = null
      target_tags             = null
      target_service_accounts = null
      allow = [{
        protocol = "udp"
        ports    = ["1-1023"]
      }]
      deny = []
      log_config = {
        metadata = "INCLUDE_ALL_METADATA"
      }
    }
  ]

}
