module "vpc" {
    source  = "terraform-google-modules/network/google"
    version = "~> 4.0"

    project_id   = data.google_project.project.id
    network_name = "lab"
    routing_mode = "GLOBAL"

    subnets = [
        {
            subnet_name           = "subnet-01"
            subnet_ip             = "10.10.10.0/24"
            subnet_region         = "us-central"
        },
        {
            subnet_name           = "subnet-02"
            subnet_ip             = "10.10.20.0/24"
            subnet_region         = "us-central1"
            subnet_private_access = "true"
            subnet_flow_logs      = "true"
            description           = "This subnet has a description"
        },
        {
            subnet_name               = "subnet-03"
            subnet_ip                 = "10.10.30.0/24"
            subnet_region             = "us-central1"
            subnet_flow_logs          = "true"
            subnet_flow_logs_interval = "INTERVAL_10_MIN"
            subnet_flow_logs_sampling = 0.7
            subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
        },
        {
            subnet_name               = "subnet-04"
            subnet_ip                 = "10.10.40.0/24"
            subnet_region             = "us-central1"
            subnet_flow_logs          = "true"
            subnet_flow_logs_interval = "INTERVAL_10_MIN"
            subnet_flow_logs_sampling = 0.7
            subnet_flow_logs_metadata = "INCLUDE_ALL_METADATA"
        }
    ]
 
    routes = [
        {
            name                   = "egress-internet"
            description            = "route through IGW to access internet"
            destination_range      = "0.0.0.0/0"
            tags                   = "egress-inet"
            next_hop_internet      = "true"
        }

    ]
    firewall_rule = [
    {
    name                    = "allow-iap"
    description             = "Allow IAP access to VM"
    direction               = "INGRESS"
    priority                = 10
    ranges                  = ["35.235.240.0/20"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = "public"
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
    name                    = "allow-http"
    description             = "All web traffic"
    direction               = "INGRESS"
    priority                = 20
    ranges                  = ["0.0.0.0/0"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = "public"
    target_service_accounts = null
    allow = [{
      protocol = "tcp"
      ports    = [
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
    name                    = "outbound"
    description             = "Allow Egress"
    direction               = "Egress"
    priority                = null
    ranges                  = ["0.0.0.0/0"]
    source_tags             = null
    source_service_accounts = null
    target_tags             = null
    target_service_accounts = null
    allow = [{
      protocol = "all",
    }]
    deny = []
    log_config = {
      metadata = "INCLUDE_ALL_METADATA"
      }
    },    
    ]
    
}
