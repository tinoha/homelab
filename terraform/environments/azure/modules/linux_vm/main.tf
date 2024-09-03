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
    private_ip_address            = var.private_ip != "" ? var.private_ip : ""
  }
}

# Create default NSG for the VM
resource "azurerm_network_security_group" "linuxvm" {
  name                = "${var.env}-${var.vm_name}-nsg"
  location            = azurerm_resource_group.linuxvm.location
  resource_group_name = azurerm_resource_group.linuxvm.name
}

# Associate default NSG to the vm interface
resource "azurerm_network_interface_security_group_association" "linuxvm" {
  network_interface_id      = azurerm_network_interface.linuxvm.id
  network_security_group_id = azurerm_network_security_group.linuxvm.id
}


# Attach vm network interface to the shared Load Balancer Backend address pool for outbound internet traffic
resource "azurerm_network_interface_backend_address_pool_association" "linuxvm" {
  # count = can(var.bap_ids[0]) ? 1 : 0  # Check if string in list position, and only then attach interface to bap.
  count                   = can(var.bap_id) && length(var.bap_id) > 1 ? 1 : 0 # Check if bap_id string is defined, and only then make the association.
  network_interface_id    = azurerm_network_interface.linuxvm.id
  ip_configuration_name   = "internal"
  backend_address_pool_id = var.bap_id
}

resource "azurerm_linux_virtual_machine" "linuxvm" {
  name                = "${var.env}-${var.vm_name}"
  resource_group_name = azurerm_resource_group.linuxvm.name
  location            = azurerm_resource_group.linuxvm.location
  size                = var.vm_sku
  priority            = var.enable_spot ? "Spot" : null
  eviction_policy     = var.enable_spot ? "Deallocate" : null
  admin_username      = var.admin_user
  admin_password      = var.admin_password

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
  tags = {
    "env" = "${var.env}"
  }
  depends_on = [azurerm_network_interface_security_group_association.linuxvm,
  azurerm_network_interface_backend_address_pool_association.linuxvm]
}

# Set Auto shutdown schedule for the created VM
# Shudown the all created VMs automatically every night
resource "null_resource" "vm_auto_shutdown" {
  count      = var.enable_auto_shutdown == true ? 1 : 0
  depends_on = [azurerm_linux_virtual_machine.linuxvm]
  provisioner "local-exec" {
    command = "az vm auto-shutdown --resource-group ${azurerm_resource_group.linuxvm.name} --name ${azurerm_linux_virtual_machine.linuxvm.name} --time 23:00"
  }
}

# Add NSG rule to allow ssh from internet
resource "azurerm_network_security_rule" "allow_internet_ssh_inbound" {
  count                       = var.allow_ssh_internet_inbound == true ? 1 : 0
  name                        = "AllowSSHInternetInbound"
  priority                    = 200
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.linuxvm.name
  network_security_group_name = azurerm_network_security_group.linuxvm.name
}

# Add default NSG rule to block all internet inbound
resource "azurerm_network_security_rule" "deny_all_internet_inbound" {
  name                        = "DenyAllInternetInbound"
  priority                    = 900
  direction                   = "Inbound"
  access                      = "Deny"
  protocol                    = "*"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.linuxvm.name
  network_security_group_name = azurerm_network_security_group.linuxvm.name
}

