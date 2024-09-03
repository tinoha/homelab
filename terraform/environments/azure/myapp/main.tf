# if terraform.workspace is set, use it as env, otherwise use var.env
locals {
  env = terraform.workspace != "default" ? terraform.workspace : var.env
}

module "scaleset_myapp" {
  source = "../modules/scaleset"

  env                  = local.env
  location             = var.location
  rg_name              = "myapp-rg"
  computer_name_prefix = "myapp"
  sset_name            = "myapp-sset"
  bap_id               = data.terraform_remote_state.shared.outputs.backend_address_pool_id
  ssh_public_key_path  = var.ssh_public_key_path
  vm_sku               = var.vm_sku
  subnet_id            = data.terraform_remote_state.shared.outputs.subnet_ids["${local.env}-app-subnet"]
  vm_count             = 2
  admin_user           = var.admin_user
  admin_password       = var.admin_password
}

