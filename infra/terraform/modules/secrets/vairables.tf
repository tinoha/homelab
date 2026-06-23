variable "location" {
  description = "The Azure region where the resource group will be created."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name."
  type        = string
}

variable "tags" {
    description = "Tags to assing to each resource"
}

variable "keyvault_name" {
  description = "Name of the Key Vault for secrets."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{3,24}$", var.keyvault_name))
    error_message = "Key Vault name must be 3-24 characters and contain only letters, numbers, and hyphens."
  }
}

variable "app_name" {
  description = "Name of the Azure AD application for accessing secrets."
  type        = string
}

# variable "secrets_populate_secrets" {
#   description = "Whether to pre-populate the Key Vault with secrets placeholders used in this homelab repository."
#   type        = bool
#   default     = false
# }


# Prepopulate secrets placeholder here as a map
# format examples:
#    "authentik-db-password"          = "Placeholder value for authentik database password" 
# Terraform state is NOT a safe place for sensitive data.
variable "secrets" {
  description = "List of secrets to pre-populate in the Key Vault as placeholders. Do not load real secrets here." 
  type        = map(string)
  default = {}
}

variable "custom_tags" {
  description = "A map of custom tags to apply to all resources. These will be merged with default tags defined in the provider configuration."
  type        = map(string)
  default     = {}
}

variable "wait_for_rbac_delay_seconds" {
    description = " # Wait seconds after creating role assignments before proceeding with creating resources that depend on those permissions."
    type = number
    default = "60"
}