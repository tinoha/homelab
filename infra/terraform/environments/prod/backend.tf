# backend.tf
terraform {
  backend "azurerm" {
    # resource_group_name  = "<resource_group_name>"
    # storage_account_name = "<storage_account_name>"
    # container_name       = "<container_name"
    key = "prod.tfstate" # Unique key per environment

    use_azuread_auth = true # Enforce the use of Azure AD based authentication for managing the storage account.
  }
}
