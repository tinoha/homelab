# Define environment to which resources are deployed.
# If unset terraform-workspace name is used. 

variable "env" {
  description = "Environment name"
  type        = string
  default     = "default"
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
  default     = "1" # small VM type for testing
}

variable "vm_sku" {
  description = "The SKU for the VM"
  default     = "Standard_B1ls" # small type for testing
}

variable "admin_user" {
  description = "Admin user for the VM"
  type        = string
  default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  default     = "T0s1sala-"
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  default     = "~/.ssh/id_rsa.pub"
}

