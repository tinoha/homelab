# Variables for default cloud-init templates

variable "data_file" {
  description = "Path to a cloud-init user-data template file."
  type        = string
  default     = "./templates/user-data.tftpl"
}

# variable "meta_file" {
#   description = "Path to a cloud-init meta-data template file"
#   type        = string
#   default     = "./templates/meta_data.tftpl"
# }

# variable "network_file" {
#   description = "Path to a cloud-init meta-data template file"
#   type        = string
#   default     = "./templates/network_data.tftpl"
# }

# Cloud-init variables available in the default user-data template (./templates/user-data.tfpl).
# Alternatively, set path to your own template (data_file) or edit the default template. 

# Variables for new Administrative user creation. cloud-init default user will also be created.
variable "username" {
  description = "User name in cloud-init"
  type        = string
  default     = "sysadmin"
}

variable "gecos" {
  description = "User description in cloud-init"
  type        = string
  default     = "System administrator"
}

variable "groups" {
  description = "Groups of the user in cloud-init"
  type        = string
  default     = "sudo"
}

variable "shell" {
  description = "Shell for the user in cloud-init"
  type        = string
  default     = "/bin/bash"
}

variable "ssh_key" {
  type = string
  default = ""
  description = "SSH public key for the user in cloud-init"
}

variable "sudo_privileges" {
  description = "Sudo privileges configuration in cloud-init"
  type        = string
  default     = "ALL=(ALL) NOPASSWD:ALL"
}

variable "password" {
  description = "Default user's password in cloud-init"
  type        = string
  default     = ""
}

variable "ssh_pwauth" {
  description = "Default user ssh login allowed with password."
  type        = bool
  default     = "false"
}

# 
variable "hostname" {
  description = "hostname in cloud-init"
  type        = string
  default     = ""
}

variable "fqdn" {
  description = "fqdn in cloud-init"
  type        = string
  default     = ""
}
