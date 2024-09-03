
# if terraform.workspace is set, use it as env, otherwise use var.env
locals {
  env = terraform.workspace != "default" ? terraform.workspace : var.env
}

module "k8s_controlplane_01" {
  source     = "../modules/linux_vm"
  env        = local.env
  location   = var.location
  rg_name    = "k8s-cluster-rg"
  vm_name    = "controlplane-01"
  private_ip = "10.80.2.10"
  #bap_ids              = [data.terraform_remote_state.shared.outputs.backend_address_pool_id]
  ssh_public_key_path = var.ssh_public_key_path
  vm_sku              = var.vm_sku
  subnet_id           = data.terraform_remote_state.shared.outputs.subnet_ids["${local.env}-k8s-subnet"]
  admin_user          = var.admin_user

}

# Shudown the VM automatically every night
resource "null_resource" "vm_auto_shutdown" {
  depends_on = [ module.k8s_controlplane_01 ]
  provisioner "local-exec" {
    command = "az vm auto-shutdown --resource-group k8s-cluster-rg --name prod-controlplane-01 --time 23:00"
  }
}



# Write vm_ip to a text file
resource "local_file" "vm_ip" {
  filename = "${path.module}/output_files/control-plane-ip.txt"
  content  = module.k8s_controlplane_01.vm_ip
}



