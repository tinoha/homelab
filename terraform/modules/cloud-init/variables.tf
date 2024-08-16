# Variables for default cloud-init templates. Check also the default user-data.tftpl content as it as other static settings not listed here.

variable "data_file" {
  description = "Path to a cloud-init user-data file with static values (no templating). When set all  When not set the default template and will be used."
  type        = string
  default     = ""
}

### user-data users: section variables ###
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

#### user-data top level variables ### 
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

variable "ssh_pwauth" {
  description = "Default user ssh login allowed with password."
  type        = string
  default     = ""
}

variable "password" {
  description = "Default user's password in cloud-init"
  type        = string
  default     = ""
}