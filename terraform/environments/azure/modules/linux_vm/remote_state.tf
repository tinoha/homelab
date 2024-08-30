# Use the local data source to read the envrionment "shared" state for testing purposes. Note that shared env must be configured also to use local state.
data "terraform_remote_state" "shared" {
  backend = "local"
  config = {
    path = "../shared/terraform.tfstate"
  }
}