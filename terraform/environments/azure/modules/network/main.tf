# Network module creates shared network infrastructure components for all environments.(vnet, subnets, default nsg for each subnet and load balancer)  

# Resource Group
resource "azurerm_resource_group" "network" {
  name     = "${var.env}-${var.rg_name}"
  location = var.location
  tags = {
    env = var.env
  }
}

# Virtual Network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.env}-${var.vnet_name}"
  address_space       = [var.vnet_address_space]
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  tags = {
    env = var.env
  }
}

# Subnets
resource "azurerm_subnet" "subnet" {
  for_each             = { for subnet in var.subnets : subnet.name => subnet }
  name                 = "${var.env}-${each.value.name}"
  address_prefixes     = [each.value.address_prefix]
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

# Default NSG subnet
resource "azurerm_network_security_group" "subnet" {
  for_each = { for subnet in var.subnets : subnet.name => subnet }
  name                = "${var.env}-${each.value.name}-nsg"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

tags = {
    env = var.env
  }

}


# Deploy standard static public IP for the shared load balancer.
resource "azurerm_public_ip" "shared_lb" {
  name                = "${var.env}-shared-lb-pip"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    env = var.env
  }

}

resource "azurerm_lb" "shared_lb" {
  name                = "${var.env}-shared-lb"
  location            = azurerm_virtual_network.vnet.location
  resource_group_name = azurerm_resource_group.network.name

  sku = "Standard"

  frontend_ip_configuration {
    name                 = "shared-fic"
    public_ip_address_id = azurerm_public_ip.shared_lb.id
  }

  tags = {
    env = var.env
  }
}

# Shared loadbalancer backend address pool
resource "azurerm_lb_backend_address_pool" "shared_lb" {
  loadbalancer_id = azurerm_lb.shared_lb.id
  name            = "${var.env}-shared-outbound-bap"

}

# Loadbalancer outbound rules for outbound internet traffic
resource "azurerm_lb_outbound_rule" "shared_lb" {
  name                    = "${var.env}-shared-utbound-rule"
  loadbalancer_id         = azurerm_lb.shared_lb.id
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.shared_lb.id

  frontend_ip_configuration {
    name = "shared-fic"
  }

}
