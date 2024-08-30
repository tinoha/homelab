resource "azurerm_resource_group" "linuxvm" {
  name     = var.rg_name
  location = var.location
}


resource "azurerm_network_interface" "linuxvm" {
  name                = "${var.env}-${var.vm_name}-nic"
  location            = azurerm_resource_group.linuxvm.location
  resource_group_name = azurerm_resource_group.linuxvm.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip != "" ? "Static" : "Dynamic"
    private_ip_address = var.private_ip != "" ? var.private_ip : ""
  }
}

resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                = "${var.env}-${var.vm_name}"
  resource_group_name = azurerm_resource_group.linuxvm.name
  location            = azurerm_resource_group.linuxvm.location
  size                = var.vm_sku
  admin_username      = var.admin_user
  

  network_interface_ids = [
    azurerm_network_interface.linuxvm.id
  ]

  admin_ssh_key {
    username   = var.admin_user
    public_key = file(var.ssh_public_key_path)
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb         = 30
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

}

