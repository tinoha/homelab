output "env" {
  value = var.env
}

output "rg_name" {
  value = azurerm_resource_group.network.name
}

output "location" {
  value = azurerm_resource_group.network.location
}

output "vnet_id" {
  value = azurerm_virtual_network.vnet.id
  description = "The Id of the Virtual Network"
}

output "vnet_name" {
  description = "The name of the Virtual Network"
  value       = azurerm_virtual_network.vnet.name
}

output "vnet_address_space" {
  description = "The address space of the Virtual Network"
  value       = azurerm_virtual_network.vnet.address_space
}

 output "subnet_ids" {
  description = "IDs of the created subnets as map"
  value = { for s in azurerm_subnet.subnet : s.name => s.id }
}

output "subnet_names" {
  description = "Names of the created subnets as map"
  value = { for s in azurerm_subnet.subnet : s.name => s.name }
}

output "subnet_address_prefixes" {
  description = "Address prefixes of the created subnets as map"
  value = { for s in azurerm_subnet.subnet : s.name => s.address_prefixes[0] }
}

output "nsg_names" {
  description = "NSGs for the subnets as map"
  value = { for nsg in azurerm_network_security_group.subnet : nsg.name => nsg.name }
}

output "nsg_ids" {
  description = "NSGs for the subnets as map"
  value = { for nsg in azurerm_network_security_group.subnet : nsg.name => nsg.id }
}

output "lb_id" {
  description = "The ID of the Load Balancer"
  value       = azurerm_lb.shared_lb.id
}

output "frontend_ip_configuration" {
  description = "Frontend IP Configuration"
  value       = azurerm_lb.shared_lb.frontend_ip_configuration
}

output "backend_address_pool_id" {
  description = "The ID of the Backend Address Pool"
  value       = azurerm_lb_backend_address_pool.shared_lb.id
}

output "lb_name" {
  description = "The name of the Load Balancer"
  value       = azurerm_lb.shared_lb.name
}

