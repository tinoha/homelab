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

# Subnets to be created
resource "azurerm_subnet" "subnet" {
  for_each             = { for subnet in var.subnets : subnet.name => subnet }
  name                 = "${var.env}-${each.value.name}"
  address_prefixes     = [each.value.address_prefix]
  resource_group_name  = azurerm_resource_group.network.name
  virtual_network_name = azurerm_virtual_network.vnet.name
}

# Default NSG subnet
resource "azurerm_network_security_group" "subnet" {
  for_each            = { for subnet in var.subnets : subnet.name => subnet }
  name                = "${var.env}-${each.value.name}-nsg"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name

  tags = {
    env = var.env
  }
}

resource "azurerm_subnet_network_security_group_association" "subnet" {
  for_each                  = azurerm_subnet.subnet
  subnet_id                 = azurerm_subnet.subnet[each.key].id
  network_security_group_id = azurerm_network_security_group.subnet[each.key].id
}


# Deploy standard static public IP for the shared load balancer.
resource "azurerm_public_ip" "shared_lb" {
  count               = var.create_loadbalancer ? 1 : 0
  name                = "${var.env}-shared-lb-pip"
  location            = azurerm_resource_group.network.location
  resource_group_name = azurerm_resource_group.network.name
  allocation_method   = "Static"
  sku                 = "Standard"
  tags = {
    env = var.env
  }

  lifecycle {
    create_before_destroy = true

  }
}

# Create standard loadbalancer
resource "azurerm_lb" "shared_lb" {
  count               = var.create_loadbalancer ? 1 : 0
  name                = "${var.env}-shared-lb"
  location            = azurerm_virtual_network.vnet.location
  resource_group_name = azurerm_resource_group.network.name

  sku = "Standard"

  frontend_ip_configuration {
    name                 = "shared-fic"
    public_ip_address_id = azurerm_public_ip.shared_lb[count.index].id
  }

  tags = {
    env = var.env
  }
}

# Shared loadbalancer backend address pool
resource "azurerm_lb_backend_address_pool" "shared_lb" {
  count           = var.create_loadbalancer ? 1 : 0
  loadbalancer_id = azurerm_lb.shared_lb[count.index].id
  name            = "${var.env}-shared-outbound-bap"

}

# Shared loadbalancer outbound rules for outbound internet traffic
resource "azurerm_lb_outbound_rule" "shared_lb" {
  count                   = var.create_loadbalancer ? 1 : 0
  name                    = "${var.env}-shared-outbound-rule"
  loadbalancer_id         = azurerm_lb.shared_lb[count.index].id
  protocol                = "All"
  backend_address_pool_id = azurerm_lb_backend_address_pool.shared_lb[count.index].id

  frontend_ip_configuration {
    name = "shared-fic"
  }

}


# Shared loadbalancer Inbound NAT rule for vms in shared backend pool
resource "azurerm_lb_nat_rule" "ssh" {
  count                          = var.create_loadbalancer ? 1 : 0
  resource_group_name            = azurerm_resource_group.network.name
  loadbalancer_id                = azurerm_lb.shared_lb[0].id
  name                           = "SSH_Access"
  protocol                       = "Tcp"
  frontend_port_start            = 42200
  frontend_port_end              = 42299
  backend_port                   = 22
  backend_address_pool_id        = azurerm_lb_backend_address_pool.shared_lb[0].id
  frontend_ip_configuration_name = "shared-fic"
}

# Add NSG rule to allow ssh from internet
resource "azurerm_network_security_rule" "allow_ssh_internet_inbound" {
  for_each                    = var.allow_ssh_internet_inbound == true ? azurerm_subnet.subnet : {}
  name                        = "AllowSSHInternetInbound"
  priority                    = 1000
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "internet"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.network.name
  network_security_group_name = azurerm_network_security_group.subnet[each.key].name
}
