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
}

variable "rg_name" {
  description = "Resource group name"
}

# Variables for the VM

variable "private_ip" {
  description = "Static Private IP for the VM, otherwise IP will be Dynamic"
  type = string
}

variable "vm_name" {
  description = "Virtual machine name"
  type = string
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

/*
variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  # default     = ""
}
*/

variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  # default     = "~/.ssh/id_rsa.pub"
}

/* variable "bap_ids" {
  description = "Backend address pool Ids"
  type = list(string)
}
*/

variable "subnet_id" {
  description = "Id of the subnet"
  type = string
}