 output "vm_ip_addresses" {
  value = length(libvirt_domain.vm) > 0 ? [ for vm in libvirt_domain.vm : vm.network_interface[0].addresses[0] if length(vm.network_interface[0].addresses) > 0 ] : []
  description = "List of IP addresses of all VMs."
}

output "vm_info" {
  value = local.vm_info
  description = "VM info as array of objects containing vm ips, names. ids..."
}