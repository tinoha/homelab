# Get the current Azure AD client configuration, which is needed for assign permissions to managing the backup storage account and secrets Key Vault with Azure AD based authentication.
locals {
   wait_for_rbac_delay_seconds = "${var.wait_for_rbac_delay_seconds}s"
}

data "azuread_client_config" "current" {}

resource "azurerm_resource_group" "secrets" {
  name     = var.resource_group_name
  location = var.location

  tags = var.tags
}

# Wait delay for RBAC propagations to the current user. 
resource "time_sleep" "wait_for_rbac" {
  depends_on = [
    azurerm_role_assignment.secrets_kv_contributor,
  ]
  create_duration = local.wait_for_rbac_delay_seconds
}

# Wait delay for RBAC propagations to current user
resource "time_sleep" "wait_for_rbac_secrets_officer" {
  count           = length(var.secrets) > 0 ? 1 : 0
  depends_on      = [azurerm_role_assignment.secrets_kv_secrets_officer]
  create_duration = local.wait_for_rbac_delay_seconds
}


resource "azurerm_role_assignment" "secrets_kv_contributor" {
  scope                = azurerm_resource_group.secrets.id
  role_definition_name = "Contributor"
  principal_id         = data.azuread_client_config.current.object_id
  description          = "Grant the current user permissions to manage the Key Vault for secrets."
}

resource "azurerm_key_vault" "secrets" {
  name                          = var.keyvault_name
  resource_group_name           = azurerm_resource_group.secrets.name
  location                      = azurerm_resource_group.secrets.location
  tenant_id                     = data.azuread_client_config.current.tenant_id

  # Hardcoded defaults:
  sku_name                      = "standard"
  soft_delete_retention_days    = 7
  rbac_authorization_enabled    = true
  purge_protection_enabled      = false
  public_network_access_enabled = true

  lifecycle {
    prevent_destroy = false
  }
  depends_on = [time_sleep.wait_for_rbac]
  tags       = var.tags
}

resource "azuread_application_registration" "secrets" {
  display_name = var.app_name
}

resource "azuread_service_principal" "secrets" {
  client_id   = azuread_application_registration.secrets.client_id
  owners      = [data.azuread_client_config.current.object_id]
  description = "Service principal for accessing secrets in the Key Vault."
}

resource "azurerm_role_assignment" "secrets_kv_secrets_user" {
  scope                = azurerm_key_vault.secrets.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azuread_service_principal.secrets.object_id
  description          = "Grant the secrets service principal permissions to access secrets in the Key Vault."
}

# Populate the Key Vault with secrets used in this homelab repository, if enabled by the variable `secrets_populate_secrets`.
# The actual values of the secrets should be updated via azure client or Azure Portal after deployment.
# The lifecycle `ignore_changes` is used to prevent Terraform from trying to revert changes to the secret values, which allows manual updates to the secrets later without causing issues with Terraform state.
# First we grant the needed permissions to the current user on the Key Vault to manage the secrets.
resource "azurerm_role_assignment" "secrets_kv_secrets_officer" {
  count                = length(var.secrets) > 0 ? 1 : 0
  scope                = azurerm_key_vault.secrets.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azuread_client_config.current.object_id
}

# Populate secret placeholders into vault when sleep timer is ready (if populate flag true.)
resource "azurerm_key_vault_secret" "secrets" {
  for_each     = var.secrets
  name         = each.key
  value        = each.value
  key_vault_id = azurerm_key_vault.secrets.id

  lifecycle {
    ignore_changes  = [value]
    prevent_destroy = true
  }
  depends_on = [time_sleep.wait_for_rbac_secrets_officer]
}
