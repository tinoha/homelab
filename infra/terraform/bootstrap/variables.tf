variable "location" {
  description = "The Azure region where the resource group will be created."
  type        = string
  default     = "swedencentral"
}

variable "project" {
  description = "Project name used in resource name and tagging."
  type        = string
}

variable "environment" {
  description = "Environment name used in resource name and tagging."
  type        = string
  default     = "bootstrap"
}

variable "name_suffix" {
  description = "Suffix appended to Azure resources, e.g. 01 to help make the resource names globally unique where needed. Default is no suffix"
  type        = string
  default     = ""
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
