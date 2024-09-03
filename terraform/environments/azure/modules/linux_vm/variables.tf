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
  type        = string
  default     = ""
}

variable "vm_name" {
  description = "Virtual machine name"
  type        = string
}


variable "vm_sku" {
  description = "The SKU for the VM"
  type        = string
  # default     = "Standard_B1ms" # small VM type for testing
}

variable "enable_spot" {
  description = "Enable spot instances with eviction policy Deallocate"
  type = bool
  default = false
} 

variable "admin_user" {
  description = "Admin user for the VM"
  type        = string
  # default     = "azureuser"
}


variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
  # default     = ""
}


variable "ssh_public_key_path" {
  description = "Path to SSH public key"
  sensitive   = true
  # default     = "~/.ssh/id_rsa.pub"
}

variable "bap_id" {
  description = "Loadbalancer Backend address pool Id"
  type        = string
  default     = ""
}

variable "subnet_id" {
  description = "Id of the subnet"
  type        = string
}

variable "enable_auto_shutdown" {
  description = "Wether to enable VM auto shutdown every day at 23:00 (time is currently hardcoded)"
  type        = bool
  default     = false
}

variable "allow_ssh_internet_inbound" {
  description = "Allow SSH access from internet"
  type        = bool
  default     = false
}
