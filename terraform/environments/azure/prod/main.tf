
# if terraform.workspace is set, use it as env, otherwise use var.env
locals {
  env = terraform.workspace != "default" ? terraform.workspace : var.env
}

# Deploy k8s controlplane VM
module "k8s_controlplane" {
  source = "../modules/linux_vm"

  env                        = local.env
  location                   = var.location
  rg_name                    = "k8s-cluster-rg"
  vm_name                    = "k8s-control-01"
  private_ip                 = "10.80.2.10"
  ssh_public_key_path        = var.ssh_public_key_path
  vm_sku                     = var.vm_sku
  subnet_id                  = data.terraform_remote_state.shared.outputs.subnet_ids["${local.env}-k8s-subnet"]
  admin_user                 = var.admin_user
  admin_password             = var.admin_password
  enable_auto_shutdown       = var.enable_auto_shutdown
  allow_ssh_internet_inbound = var.allow_ssh_internet
  enable_spot                = var.enable_spot
  # Associate VM to shared load balancer bap tp allow internet access via reserved public ip.   
  bap_id = data.terraform_remote_state.shared.outputs.backend_address_pool_id
}

# Deploy k8s worker node VM
module "k8s_worker" {
  source = "../modules/linux_vm"

  env                        = local.env
  location                   = var.location
  rg_name                    = "k8s-cluster-rg"
  vm_name                    = "k8s-node-01"
  private_ip                 = "10.80.2.20"
  ssh_public_key_path        = var.ssh_public_key_path
  vm_sku                     = var.vm_sku
  subnet_id                  = data.terraform_remote_state.shared.outputs.subnet_ids["${local.env}-k8s-subnet"]
  admin_user                 = var.admin_user
  admin_password             = var.admin_password
  enable_auto_shutdown       = var.enable_auto_shutdown
  allow_ssh_internet_inbound = var.allow_ssh_internet
  enable_spot                = var.enable_spot
  # Add VM to shared load balancer bap and outbound rules to allow internet access via reserved public ip   
  bap_id = data.terraform_remote_state.shared.outputs.backend_address_pool_id
}

# Create an array with all created VM ip, name and role to be used for ansible inventory creation
# Output as JSON array
locals {
  vm_info = concat(
    [
      for vm in module.k8s_controlplane.* : {
        name       = vm.vm_name
        private_ip = vm.vm_ip
        role       = "k8s_controlplane" # Add a role identifier
        id         = vm.vm_id
        env        = local.env
      }
    ],
    [
      for vm in module.k8s_worker.* : {
        name       = vm.vm_name
        private_ip = vm.vm_ip
        role       = "k8s_worker" # Add a role identifier
        id         = vm.vm_id
        env        = local.env
      }
    ]
  )
}

# Write vm_info to a text file
resource "local_file" "vm_info" {
  filename = "${path.module}/output_files/${var.env}-vm-info-output.json"
  content  = jsonencode(local.vm_info)
}
