output "storage_account" {
    description = "Storage account for backup usage"
    value = {
        id = azurerm_storage_account.backup.id
        name = azurerm_storage_account.backup.name
        primary_blob_endpoint   = azurerm_storage_account.backup.primary_blob_endpoint
    }
}

output "service_principal" {
  description = "Service principal used for accessing backup storage account"
  value = {
    client_id = azuread_application_registration.backup.client_id
    # client_secret    = azuread_service_principal_password.backup.value
    sp_object_id = azuread_service_principal.backup.object_id
    app_object_id    = azuread_application_registration.backup.object_id
    display_name = azuread_application_registration.backup.display_name
  }
}
