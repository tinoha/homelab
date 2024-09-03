# Define environment variable (dev or prod).
variable "env" {
  description = "Environment name. Is added as prefix for network resources."
  type        = string
  default     = ""
}

# Define the resource group name
variable "rg_name" {
  description = "Resource group name."
  type        = string
}

# Define the Azure region variable
variable "location" {
  description = "Azure region where resources will be created."
  type        = string
}

variable "vnet_address_space" {
  description = "Address space for the virtual network."
  type        = string
}

variable "vnet_name" {
  description = "Name for the virtual network."
  type        = string
}


variable "subnets" {
  description = "List of subnet names and address prefixes"
  type = list(object({
    name           = string
    address_prefix = string
  }))
}

variable "create_loadbalancer" {
  description = "Create the shared load balancer or not "
  type        = bool
}

variable "allow_ssh_internet_inbound" {
  description = "Allow SSH access from internet to subnets"
  type        = bool
  default     = false
}