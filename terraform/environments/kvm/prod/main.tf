module "libvirt_vm" {
  source      = "../../../modules/libvirt_vm"
  libvirt_uri = var.libvirt_uri

  # Module libvirt_vm variables for VM creation. 
  volume_pool            = var.volume_pool
  cloudinit_pool         = var.cloudinit_pool
  image_source           = var.image_source
  vm_name                = var.vm_name
  vm_count               = var.vm_count
  vm_vcpu                = var.vm_vcpu
  vm_memory              = var.vm_memory
  os_volume_size         = var.os_volume_size
  vm_qemu_agent          = var.vm_qemu_agent
  network_bridge         = var.network_bridge
  network_wait_for_lease = var.network_wait_for_lease

  # Module cloud-init variables
  data_file       = var.data_file
  username        = var.username
  gecos           = var.gecos
  groups          = var.groups
  shell           = var.shell
  ssh_key         = var.ssh_key
  sudo_privileges = var.sudo_privileges
  ssh_pwauth      = var.ssh_pwauth
  password        = var.password
}

# Write vm_ips to a text file
resource "local_file" "vm_ips" {
  filename = "${path.module}/output_files/vm_ips_output.txt"
  content  = join("\n", module.libvirt_vm.vm_ip_addresses)
}

# Write vm_info to a text file
resource "local_file" "vm_info" {
  filename = "${path.module}/output_files/vm_info_output.txt"
  content  = join("\n", module.libvirt_vm.vm_ip_addresses)
}