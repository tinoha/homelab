module "libvirt_vm" {
  source = "../../modules/libvirt_vm"

  libvirt_uri = "qemu:///system"

  # Module libvirt_vm variables for VM creation. 
  volume_pool            = "Images-lvm-fs"
  cloudinit_pool         = "Images-lvm-fs"
  image_source           = "/home/tino/Documents/iso/noble-server-cloudimg-amd64.img"
  vm_name                = "tfvm"
  vm_count               = "1"
  vm_vcpu                = "2"
  vm_memory              = "4096"
  vm_qemu_agent          = "true"
  network_bridge         = "br0"
  network_wait_for_lease = "true"

  #cloud_init_data_file = "" 
}

# Output IP addresses of the VMs (array)
output "vm_ips" {
  value = module.libvirt_vm.vm_ip_addresses
}

# Write vm_ips to a text file
resource "local_file" "vm_ips" {
  filename = "${path.module}/vm_ips.txt"
  content  = join("\n", module.libvirt_vm.vm_ip_addresses)
}