# Output IP addresses of the VMs (array)
output "vm_ips" {
  value = module.libvirt_vm.vm_ip_addresses
}

output "vm_info" {
  value       = module.libvirt_vm.vm_info
  description = "VM info as array of objects containing vm ips, names. ids..."
}

