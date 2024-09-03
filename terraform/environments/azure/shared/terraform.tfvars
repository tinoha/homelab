# Environment, Default is prod.
# env = "prod"

# Azure region, Default is eastus
# location = "eastus"

# Allow SSH access to all subnets from internet
allow_ssh_internet_inbound = true

# Production environment network IP ranges example values, which are also current defaults.
# These example prod network address ranges matches the addresses in 
# ../prod environment which deploys ubuntu vms for kubernetes use.  
# prod_vnet_address_space = "10.80.0.0/16"
# prod_vnet_name          = "shared-vnet"
# prod_subnets = [
#  {
#    address_prefix = "10.80.0.0/24"
#    name           = "mgmt-subnet"
#  },
#  {
#    address_prefix = "10.80.1.0/24"
#    name           = "app-subnet"
#  },
#  {
#    address_prefix = "10.80.2.0/24"
#    name           = "k8s-subnet"
#  },
#]

# Development environment network IP ranges example values.
# dev_vnet_address_space = "10.81.0.0/16"
# dev_vnet_name          = "shared-vnet"

# dev_subnets = [
#  {
#    address_prefix = "10.81.0.0/24"
#    name           = "mgmt-subnet"
#  },
#  {
#    address_prefix = "10.81.1.0/24"
#    name           = "app-subnet"
#  },
#  {
#    address_prefix = "10.81.2.0/24"
#    name           = "k8s-subnet"
#}]

# Create loadbalancer with outbound rules for vm outbound internet via the reserved public ip.
# create_loadbalancer = true
