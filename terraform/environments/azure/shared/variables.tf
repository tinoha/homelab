variable "az_subscription_id" {
  description = "Azure subscription id"
  type        = string
}

# Define environment name to which resources are deployed.
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
  description = "Resource group name suffix."
  type        = string
  default     = "shared-network-rg"
}


# Define Dev environment IP ranges
variable "dev_vnet_name" {
  description = "Name suffix for the Dev virtual network."
  type        = string
  default     = ""
}

variable "dev_vnet_address_space" {
  description = "Address space for the dev virtual network."
  type        = string
  default     = ""
}

variable "dev_subnets" {
  description = "List of subnet names and address prefixes of Dev environment"
  type = list(object({
    name           = string
    address_prefix = string
  }))
  default = [{
    address_prefix = ""
    name           = ""
  }]
}

# Define Prod environment network IP ranges
variable "prod_vnet_name" {
  description = "Name suffix for the prod virtual network."
  type        = string
  default     = "shared-vnet"
}

variable "prod_vnet_address_space" {
  description = "Address space for the prod virtual network."
  type        = string
  default     = "10.80.0.0/16"
}

variable "prod_subnets" {
  description = "List of subnet names and address prefixes for the prod virtual network"
  type = list(object({
    name           = string
    address_prefix = string
  }))
  default = [
    {
      address_prefix = "10.80.0.0/24"
      name           = "mgmt-subnet"
    },
    {
      address_prefix = "10.80.1.0/24"
      name           = "app-subnet"
    },
    {
      address_prefix = "10.80.2.0/24"
      name           = "k8s-subnet"
    },
  ]
}

# Default environment IP ranges

variable "default_vnet_name" {
  description = "Name suffix for the default virtual network."
  type        = string
  default     = "shared-vnet"
}

variable "default_vnet_address_space" {
  description = "Address space for the prod virtual network."
  type        = string
  default     = "10.10.0.0/16"
}

variable "default_subnets" {
  description = "List of subnet names and address prefixes of default environment"
  type = list(object({
    name           = string
    address_prefix = string
  }))
  default = [
    {
      address_prefix = "10.10.1.0/24"
      name           = "mgmt-subnet"
    },
    {
      address_prefix = "10.10.2.0/24"
      name           = "default-subnet"
  }]
}


variable "create_loadbalancer" {
  description = "Create the shared load balancer or not "
  type        = bool
  default     = true
}

variable "allow_ssh_internet_inbound" {
  description = "Allow ssh from internet to all subnets"
  type        = bool
  default     = false
}