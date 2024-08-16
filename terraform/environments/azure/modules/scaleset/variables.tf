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
 # default     = "1" # small VM type for testing
}

variable "vm_sku" {
  description = "The SKU for the VM"
  type = string
  # default     = "Standard_B1ms" # small VM type for testing
}

variable "admin_user" {
  description = "Admin user for the VM"
  type        = string
  # default     = "azureuser"
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  # default     = ""
}

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  # default     = "~/.ssh/id_rsa.pub"
}

variable "bap_ids" {
  description = "Backend address pool Ids"
  type = list(string)
}

variable "subnet_id" {
  description = "Id of the subnet"
  type = string
}