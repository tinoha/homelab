output "vm_ip_addresses" {
  # value = libvirt_domain.vm[0].network_interface[0].addresses[0]
  value = libvirt_domain.vm[*].network_interface[0].addresses[0]
  description = "List of IP addresses of all VMs."
}

