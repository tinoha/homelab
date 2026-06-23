variable "location" {
  description = "The Azure region where the resource group will be created."
  type        = string
  default     = "swedencentral"
}

variable "resource_group_name_prefix" {
  description = "The name of the resource group to create."
  type        = string
  default     = "hlab-tfstate"
}

variable "storage_account_name" {
  description = "The name of the storage account to create."
  type        = string
  default     = "hlabtfstate"

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{2,23}$", var.storage_account_name))
    error_message = "Prefix must start with a lowercase letter and contain only a-z and 0-9."
  }
}

variable "tfstate_name" {
  description = "Terraform state container name"
  type        = string
  default     = "tfstate"
}

variable "custom_tags" {
  description = "A map of custom tags to apply to all resources. These will be merged with default tags defined in the provider configuration."
  type        = map(string)
  default     = {}
}
