locals {
  # if terraform.workspace is set, use it as env, otherwise use var.env
  env = terraform.workspace != "default" ? terraform.workspace : var.env

  env_spec = {
    dev = {
      vnet_address_space = var.dev_vnet_address_space
      vnet_name          = var.dev_vnet_name
      subnets            = var.dev_subnets
      location           = var.location
      rg_name            = var.rg_name
    }
    prod = {
      vnet_address_space = var.prod_vnet_address_space
      vnet_name          = var.prod_vnet_name
      subnets            = var.prod_subnets
      location           = var.location
      rg_name            = var.rg_name
    }
    default = {
      vnet_address_space = var.default_vnet_address_space
      vnet_name          = var.default_vnet_name
      subnets            = var.default_subnets
      location           = var.location
      rg_name            = var.rg_name
    }
  }
  # If local.env is set check also relevant env_spec is available. If not, revert to default
  current_env = contains(keys(local.env_spec), local.env) ? local.env : "default"

  # set environment variables.
  environment = local.env_spec[local.current_env]

}

# Network module creates shared network infrastructure components for all environments. (vnet, subnets, default nsg for each subnet and load balancer)  

module "network" {
  source = "../modules/network"

  env                 = local.current_env
  location            = local.environment.location
  rg_name             = local.environment.rg_name
  vnet_address_space  = local.environment.vnet_address_space
  vnet_name           = local.environment.vnet_name
  subnets             = local.environment.subnets
  create_loadbalancer = var.create_loadbalancer
}

