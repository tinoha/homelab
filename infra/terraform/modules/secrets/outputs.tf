output "key_vault" {
  description = "Key Vault identifiers and endpoint used for secret storage and access configuration" 
  value = {
    id        = azurerm_key_vault.secrets.id
    name      = azurerm_key_vault.secrets.name
    uri       = azurerm_key_vault.secrets.vault_uri
    rg_name   = azurerm_resource_group.secrets.name
  }
}

output "service_principal" {
  description = "Service principal used for accessing secrets Key Vault"
  value = {
    client_id = azuread_application_registration.secrets.client_id
    sp_object_id = azuread_service_principal.secrets.object_id
    app_object_id    = azuread_application_registration.secrets.object_id
    display_name = azuread_application_registration.secrets.display_name
  }
}
