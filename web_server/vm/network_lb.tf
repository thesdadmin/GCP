# module "gce-lb-http" {
#   source            = "GoogleCloudPlatform/lb-http/google"
#   version           = "~> 4.4"

#   project           = "my-project-id"
#   name              = "group-http-lb"
#   target_tags       = [module.mig1.target_tags, module.mig2.target_tags]
#   backends = {
#     default = {
#       description                     = null
#       protocol                        = "HTTP"
#       port                            = var.service_port
#       port_name                       = var.service_port_name
#       timeout_sec                     = 10
#       enable_cdn                      = false
#       custom_request_headers          = null
#       custom_response_headers         = null
#       security_policy                 = null

#       connection_draining_timeout_sec = null
#       session_affinity                = null
#       affinity_cookie_ttl_sec         = null

#       health_check = {
#         check_interval_sec  = null
#         timeout_sec         = null
#         healthy_threshold   = null
#         unhealthy_threshold = null
#         request_path        = "/"
#         port                = var.service_port
#         host                = null
#         logging             = null
#       }

#       log_config = {
#         enable = true
#         sample_rate = 1.0
#       }

#       groups = [
#         {
#           # Each node pool instance group should be added to the backend.
#           group                        = var.backend
#           balancing_mode               = null
#           capacity_scaler              = null
#           description                  = null
#           max_connections              = null
#           max_connections_per_instance = null
#           max_connections_per_endpoint = null
#           max_rate                     = null
#           max_rate_per_instance        = null
#           max_rate_per_endpoint        = null
#           max_utilization              = null
#         },
#       ]

#       iap_config = {
#         enable               = false
#         oauth2_client_id     = null
#         oauth2_client_secret = null
#       }
#     }
#   }
# }