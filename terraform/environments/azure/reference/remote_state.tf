# Use remote_state.tf of the shared envrionment
/* data "terraform_remote_state" "shared" {
  backend = "azurerm"
  config = {
    resource_group_name  = "tfstate-rg"
    storage_account_name = "tfstateaccount2024"
    container_name       = "tfstate-container"
    key                  = "terraform-shared-tfstate"
  }
}
*/

# Use the local data source to read the envrionment "shared" state for testing purposes. Note that shared env must be configured also to use local state.
data "terraform_remote_state" "shared" {
  backend = "local"
  config = {
    path = "../shared/terraform.tfstate"
  }
}