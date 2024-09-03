variable "az_subscription_id" {
  description = "Azure subscription id"
  type        = string
}

# Define environment to which resources are deployed.
variable "env" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

# Define the Azure region variable where resources are deployed
variable "location" {
  description = "Azure region where resources will be created."
  type        = string
  default     = "eastus"

}

variable "rg_name" {
  description = "Resource group name"
  type        = string
  default     = "linuxvm-rg"
}

# Variables for the VM


variable "vm_name" {
  description = "Virtual machine name"
  type        = string
  default     = "linux-vm"
}

variable "vm_sku" {
  description = "The SKU for the VM"
  type        = string
  default     = "Standard_B2s" # 4c/4GB
}

variable "enable_spot" {
  description = "Enable spot instances with eviction policy Deallocate"
  type        = bool
  default     = false
}

variable "admin_user" {
  description = "Admin user for the VM"
  type        = string
  default     = "sysadmin"
}


variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  default     = null
  sensitive   = true
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  type        = string
  default     = "~/.ssh/id_ed25519_sysadmin.pub"
}

variable "bap_id" {
  description = "Loadbalancer Backend address pool Id"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Id of the subnet"
  type        = string
  default     = ""
}

variable "enable_auto_shutdown" {
  description = "Wether to enable VM auto shutdown every day at 23:00 (time is hardcoded)"
  type        = bool
  default     = false
}


variable "allow_ssh_internet" {
  description = "Allow SSH access from internet"
  type        = bool
  default     = false
}
