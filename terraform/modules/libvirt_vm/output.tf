output "vm_ip_addresses" {
  value = var.vm_qemu_agent == true && var.network_wait_for_lease == true ?  libvirt_domain.vm[*].network_interface[0].addresses[0] : []
  description = "List of IP addresses of all VMs."
}

