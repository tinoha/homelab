variable "location" {
  description = "The Azure region where the resources will be created."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name for backups storage acount."
  type        = string
  default     = "hlab-backup"
}

variable "storage_account_name" {
  description = "Storage account name."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9]{2,23}$", var.storage_account_name))
    error_message = "Name must start with a lowercase letter and contain only a-z and 0-9."
  }
}

variable "container_names" {
  description = "List of container names to be created"
  type = set(string)
  default = []
}

variable "app_name" {
  description = "Name of the Azure AD application for backup operations."
  type        = string
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}

variable "wait_for_rbac_delay_seconds" {
  description = " # Wait seconds after creating role assignments before proceeding with creating resources that depend on those permissions."
  type        = number
  default     = "60"
}
