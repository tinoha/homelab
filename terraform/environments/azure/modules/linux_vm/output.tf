output "vm_ip" {
  value = azurerm_linux_virtual_machine.linuxvm.private_ip_address
}

output "vm_name" {
  value = azurerm_linux_virtual_machine.linuxvm.computer_name
}

output "vm_id" {
  value = azurerm_linux_virtual_machine.linuxvm.id
}