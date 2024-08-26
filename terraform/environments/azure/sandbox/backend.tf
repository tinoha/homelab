# Use remote terraform remote state for production envs. Here is an example how to use Azure storage account as backend.
/*terraform {
  backend "azurerm" {
    resource_group_name  = "tfstate-rg"                  # Shared resource group for all environments
    storage_account_name = "tfstateaccount2024"          # Shared storage account
    container_name       = "tfstate-container"           # Shared container
    key                  = "terraform-reference-tfstate" # Unique key per environment
  }
}
*/