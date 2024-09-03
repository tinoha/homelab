
# Resource Group
resource "azurerm_resource_group" "sset" {
  name     = "${var.env}-${var.rg_name}"
  location = var.location
  
  tags = {
    env = var.env
  }
}

# Orchestrated VM Scale Set
resource "azurerm_orchestrated_virtual_machine_scale_set" "sset" {
  name                = "${var.env}-${var.sset_name}"
  
  location            = azurerm_resource_group.sset.location
  resource_group_name = azurerm_resource_group.sset.name

  platform_fault_domain_count = 1
  instances                   = var.vm_count
  
  # VM Profile 
  sku_name = var.vm_sku
  os_profile {
    linux_configuration {
      computer_name_prefix = var.computer_name_prefix
      admin_username = var.admin_user
      admin_password = var.admin_password
      admin_ssh_key {
        username   = var.admin_user
        public_key = file(var.ssh_public_key_path)
      }
    }
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

  network_interface {
    name    = "nic-${var.env}-${var.computer_name_prefix}"
    primary = true

    ip_configuration {
      name      = "ipconfig"
      subnet_id = var.subnet_id
      primary = true

      # Attach to Load Balancer's Backend Pool
      load_balancer_backend_address_pool_ids = can(var.bap_id) && length(var.bap_id) > 1 ? [var.bap_id] : null 
     }
  }

  tags = {
    env = var.env
  }

}

