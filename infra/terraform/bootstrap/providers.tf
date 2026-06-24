# providers.tf

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
  storage_use_azuread = true # Enforce the use of Azure AD based authentication for managing the storage account and blob data, which is more secure than access keys based authentication.
}

provider "azuread" {
  # Configurations go here ...
}
