variable "az_subscription_id" {
  description = "Azure subscription id"
  type        = string
}

# Define environment to which resources are deployed.
# If unset terraform-workspace name is used. 
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

# Variables for VMs

variable "vm_count" {
  description = "Count of the VM's"
  type        = number
  default     = 1
}

variable "vm_sku" {
  description = "The SKU for the VM"
  default     = "Standard_B1ls" # small type for testing
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
  description = "SSH public key path"
  type        = string
  default     = "~/.ssh/id_ed25519_sysadmin.pub"
}

