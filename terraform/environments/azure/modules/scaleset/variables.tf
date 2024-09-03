# Define environment to which resources are deployed.
# If unset terraform-workspace name is used. 

variable "env" {
  description = "Environment name"
  type        = string
  default     = ""
}

# Define the Azure region variable where resources are deployed
variable "location" {
  description = "Azure region where resources will be created."
  type        = string
  # default     = "eastus"
}

variable "rg_name" {
  description = "Resource group name"
}

# Variables for scaleset and vms

variable "sset_name" {
  description = "Scaleset name"
  type = string
}

variable "computer_name_prefix" {
  description = "Scaleset name"
  type = string
}

variable "vm_count" {
  description = "Count of the VM's"
  type = number
  default     = 1
}

variable "vm_sku" {
  description = "The SKU for the VM"
  type = string
  # default     = "Standard_B1ms" # small VM type for testing
}

variable "admin_user" {
  description = "Admin user for the VM"
  type        = string
 }

 variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive = true
  default = null
}

variable "ssh_public_key_path" {
  description = "SSH public key path"
  type = string
  sensitive = true
}

variable "bap_id" {
  description = "Load balancer Backend address pool Id"
  type = string
  default = ""
}

variable "subnet_id" {
  description = "Id of the subnet"
  type = string
}