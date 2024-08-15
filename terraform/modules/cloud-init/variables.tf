# Variables for default cloud-init templates

variable "data_file" {
  description = "Path to a cloud-init user-data template file."
  type        = string
  default     = "./templates/user-data.tftpl"
}

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
  type        = string
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
