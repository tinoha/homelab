# main.tf

## Bootstrap Terraform configuration to create the remote state storage for all other Terraform configurations.
# This should be run only once before running any other Terraform configurations.

locals {
  # Wait seconds after creating role assignments before proceeding with creating resources that depend on those permissions. 
  # RBAC permissions in Azure can take some time to propagate, and without this delay, the subsequent resource creations might fail due to insufficient permissions.
  wait_for_rbac_delay_seconds = 45

  resource_group_name = "rg-${var.project}-tfstate"

  storage_account_name = join("", compact([
    var.project,
    "tfstate",
    var.name_suffix
  ]))

  # Merge custom tags from variable with default tags below. if there are any overlapping keys, the values from `var.custom_tags` will take precedence.
  merged_tags = merge(
    {
      "project"     = "${var.project}"
      "environment" = "${var.environment}"
      "managed-by"  = "terraform"
    },
    var.custom_tags
  )
}

# Get the current Azure AD client configuration.
# Used to assign permissions to the current user for managing the storage account and blob data.
data "azuread_client_config" "current" {}

# Wait delay for RBAC propagations to the current user. 
resource "time_sleep" "wait_for_rbac" {
  depends_on = [
    azurerm_role_assignment.tfstate,
    azurerm_role_assignment.tfstate_data
  ]
  create_duration = "${local.wait_for_rbac_delay_seconds}s"
}

resource "azurerm_resource_group" "tfstate" {
  name     = local.resource_group_name
  location = var.location

  tags = local.merged_tags
}

# Grant the current user RBAC permissions to manage the storage account and blob data, so that we can use it as the remote state storage for Terraform.
# This is needed so that we can create the storage account with access keys based authentication disabled, and use only Azure AD based authentication, which is more secure.
# For simplicity we grant the needed permissions on resource group level.
resource "azurerm_role_assignment" "tfstate" {
  scope                = azurerm_resource_group.tfstate.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = data.azuread_client_config.current.object_id
}

resource "azurerm_role_assignment" "tfstate_data" {
  scope                = azurerm_resource_group.tfstate.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = data.azuread_client_config.current.object_id
}

resource "azurerm_storage_account" "tfstate" {
  name                            = local.storage_account_name
  resource_group_name             = azurerm_resource_group.tfstate.name
  location                        = azurerm_resource_group.tfstate.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  public_network_access_enabled   = true
  shared_access_key_enabled       = false # Disable access keys based authentication to enforce the use of Azure AD based authentication.
  https_traffic_only_enabled      = true
  allow_nested_items_to_be_public = false

  # Prevent accidental deletion of the storageaccount, which would cause the loss of the Terraform state used by all other Terraform configurations. 
  lifecycle {
    prevent_destroy = true
    precondition {
      condition     = can(regex("^[a-z][a-z0-9]{2,23}$", local.storage_account_name))
      error_message = "Storage account name must start with a lowercase letter and contain only a-z and 0-9, with a total length of 3-24 characters."
    }
  }

  # Wait delay before managing storage account
  depends_on = [
    time_sleep.wait_for_rbac
  ]

  tags = local.merged_tags
}

# resource "azurerm_management_lock" "tfstate" {
#   name       = "prevent-st-deletion"
#   scope      = azurerm_storage_account.tfstate.id
#   lock_level = "CanNotDelete"
# }

resource "azurerm_storage_container" "tfstate" {
  name                  = var.tfstate_name
  storage_account_id    = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}
