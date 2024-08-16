output "env" {
  value = module.network.env
}

output "rg_name" {
  value = module.network.rg_name
}

output "location" {
  value = module.network.location
}

output "vnet_id" {
  value       = module.network.vnet_id
  description = "The Id of the Virtual Network"
}

output "vnet_name" {
  description = "The name of the Virtual Network"
  value       = module.network.vnet_name
}

output "vnet_address_space" {
  description = "The address space of the Virtual Network"
  value       = module.network.vnet_address_space
}

output "subnet_ids" {
  description = "IDs of the created subnets as map"
  value       = module.network.subnet_ids
}

output "subnet_names" {
  description = "Names of the created subnets as map"
  value       = module.network.subnet_names
}

output "subnet_address_prefixes" {
  description = "Address prefixes of the created subnets as map"
  value       = module.network.subnet_address_prefixes
}

output "nsg_names" {
  description = "NSG names for the subnets"
  value       = module.network.nsg_names
}

output "nsg_ids" {
  description = "NSG Ids"
  value       = module.network.nsg_ids
}

output "lb_id" {
  description = "The ID of the Load Balancer"
  value       = module.network.lb_id
}

output "frontend_ip_configuration" {
  description = "Frontend IP Configuration"
  value       = module.network.frontend_ip_configuration
}

output "backend_address_pool_id" {
  description = "The ID of the Backend Address Pool"
  value       = module.network.backend_address_pool_id
}

output "lb_name" {
  description = "The name of the Load Balancer"
  value       = module.network.lb_name
}
