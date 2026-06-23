# backend.tf
terraform {
  backend "azurerm" {
    resource_group_name  = "rg-hlab-tfstate"
    storage_account_name = "hlabtfstate"
    container_name       = "tfstate"
    key                  = "prod.tfstate" # Unique key per environment

    use_azuread_auth = true # Enforce the use of Azure AD based authentication for managing the storage account.
  }
}
