variable "vm_size" {
  default = ""
}
//define vm size

variable "service_port" {
  default = "80"
}
//TCP port for Load Balancer
variable "app_name" {
  default = ""
}
//Application Name for the LB
variable "app_project" {
  default = ""
}
//Project ID. Needed for resources

variable "service_port_name" {
  default = ""
}

//Port name. Needed for LB. 