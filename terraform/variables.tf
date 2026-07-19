# data for hiding during "terraform plan/apply"
variable "token" {
  description = "cloud service account token"
  type        = string
  sensitive   = true
}

variable "organization_id" {
  description = "Organization ID"
  type        = string
  sensitive   = true
}

variable "cloud_name" {
  description = "Cloud name"
  type        = string
  sensitive   = false
}

variable "cloud_id" {
  description = "Cloud ID"
  type        = string
  sensitive   = true
}

variable "folder_name" {
  description = "Catalogue name in yandex.cloud"
  type        = string
  sensitive   = false
}

variable "folder_id" {
  description = "Catalogue ID in yandex.cloud(cloud_id)"
  type        = string
  sensitive   = true
}

variable "region" {
  description = "Region for cloud resources"
  type        = string
  sensitive   = true
}

variable "zone" {
  description = "Zone for cloud resources"
  type        = string
  sensitive   = true
}

variable "ya_cloud_network" {
  description = "Main server network"
  type        = string
  sensitive   = false
}
variable "ya_cloud_network_id" {
  description = "Main server network ID"
  type        = string
  sensitive   = true
}

variable "ya_cloud_subnet_main" {
  description = "main subnet name"
  type        = string
  sensitive   = false
}

# variable "ya_cloud_subnet_main_id" {
#   description = "main subnet ID"
#   type        = string
#   sensitive   = true
# }

variable "ya_cloud_subnet_cidr" {
  description = "main subnet CIDR"
  type        = string
  sensitive   = true
}

variable "reserved_external_ip" {
  description = "Reserved external IP addresses"
  type = list(
    object({
      name  = string,
      value = string
    })
  )
}

variable "yc_subnets_prefix_list" {
  description = "Subnet prefix list"
  type    = list(string)
}

## --> Images
variable "ubuntu2604_image_id" {
  description = "OS image ID of ubuntu-2604"
  type        = string
  sensitive   = false
}
 
## <-- Images

# # --> OS Login
# variable "os_login" {
#   description = "Record for the os_login_ssh settings"
#   sensitive   = false

#   type = object({
#     ssh_subject_id = string,
#     ssh_data       = string,
#     ssh_name       = string,
#     ssh_expires_at = string
#   })
#   default = {
#     ssh_subject_id = "<user id OR service account with ssh key id>",
#     ssh_data       = "<PUB part of ssh key>",
#     ssh_name       = "<name of the ssh key>",
#     ssh_expires_at = "<life of the ssh key. Format: YYYY-MM-DDT00:00:00Z (https://ru.wikipedia.org/wiki/ISO_8601)>"
#   }
# }
# # <-- OS Login

# Route tables
variable "route_table_main" {
  description = "Main route table"
  type        = string
  sensitive   = false
}


# VMs
variable "vm_front" {
  description = "VM HTTPS gateway"
  type        = string
  sensitive   = false
}
variable "vm_front_disk" {
  description = "VM front disk"
  type        = string
  sensitive   = false
}

variable "vm_nexus" {
  description = "VM nexus"
  type        = string
  sensitive   = false
}
variable "vm_nexus_disk" {
  description = "VM nexus disk"
  type        = string
  sensitive   = false
}

variable "vm_obs" {
  description = "VM observability"
  type        = string
  sensitive   = false
}
variable "vm_obs_disk" {
  description = "VM observability disk"
  type        = string
  sensitive   = false
}