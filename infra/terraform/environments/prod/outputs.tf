output "secrets_key_vault" {
  description = "Key Vault identifiers and endpoint used for secret storage and access configuration"
  value = {
    id   = module.secrets.key_vault.id
    name = module.secrets.key_vault.name
    uri  = module.secrets.key_vault.uri
    # rg_name = module.secrets.key_vault.rg_name
  }
}

output "secrets_service_principal" {
  description = "Service principal used for accessing secrets Key Vault"
  value = {
    sp_object_id  = module.secrets.service_principal.sp_object_id
    client_id     = module.secrets.service_principal.client_id
    app_object_id = module.secrets.service_principal.app_object_id
    display_name  = module.secrets.service_principal.display_name
  }
}

output "backup_storage_account" {
  description = "Storage account for backup usage"
  value = {
    id            = module.backup.storage_account.id
    name          = module.backup.storage_account.name
    blob_endpoint = module.backup.storage_account.primary_blob_endpoint
  }
}

output "backup_service_principal" {
  description = "Service principal used for accessing backup storage account"
  value = {
    sp_object_id  = module.backup.service_principal.sp_object_id
    client_id     = module.backup.service_principal.client_id
    app_object_id = module.backup.service_principal.app_object_id
    display_name  = module.backup.service_principal.display_name
  }
}
