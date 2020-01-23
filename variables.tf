## Azure config variables ##
variable "client_id" {}

variable "client_secret" {}

variable location {
  default = "East US"
}

## Resource group variables ##
variable resource_group_name {
  default = "MC_DefaultResourceGroup-EUS_kubclu2_eastus"
}


## AKS kubernetes cluster variables ##
variable cluster_name {
  default = "pk1"
}

variable "agent_count" {
  default = 3
}

variable "dns_prefix" {
  default = "pk1-dns"
}

variable "admin_username" {
    default = "183343"
}