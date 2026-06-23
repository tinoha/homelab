locals {
  wait_for_rbac_delay_seconds = "${var.wait_for_rbac_delay_seconds}s"
}

data "azuread_client_config" "current" {}

resource "azurerm_resource_group" "backup" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# Wait delay for RBAC propagations to the current user. 
resource "time_sleep" "wait_for_rbac" {
  depends_on = [
    azurerm_role_assignment.backup_st_contributor,
  ]
  create_duration = local.wait_for_rbac_delay_seconds
}

resource "azurerm_role_assignment" "backup_st_contributor" {
  scope                = azurerm_resource_group.backup.id
  role_definition_name = "Storage Account Contributor"
  principal_id         = data.azuread_client_config.current.object_id
  description          = "Grant the current user permissions to manage the backup storage account."
}

resource "azurerm_storage_account" "backup" {
  name                          = var.storage_account_name
  resource_group_name           = azurerm_resource_group.backup.name
  location                      = azurerm_resource_group.backup.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  public_network_access_enabled = true
  shared_access_key_enabled     = false

  tags       = var.tags
  depends_on = [time_sleep.wait_for_rbac]
}

# Create an Azure AD application and service principal for backup operations
resource "azuread_application_registration" "backup" {
  display_name = var.app_name
}

# Create a service principal for the backup application
resource "azuread_service_principal" "backup" {
  client_id   = azuread_application_registration.backup.client_id
  owners      = [data.azuread_client_config.current.object_id]
  description = "Service principal for backup operations."
}

# Grant the backup service principal RBAC permissions to manage blobs in the backup storage account.
resource "azurerm_role_assignment" "backup_st_blob" {
  scope                = azurerm_storage_account.backup.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azuread_service_principal.backup.object_id
  description          = "Grant the backup service principal permissions to manage blobs in the backup storage account."
}
