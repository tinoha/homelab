# Set your Azure subscription_id:
#   az_subscription_id = "your-azure-subscription-id"

# Alternatively, set Azure subscription_id as shell environment variable:
#   export TF_VAR_az_subscription_id="your-azure-subscription-id"

# Azure region
# location = "eastus"

# Environment name
# env = "prod"

# VM variables
# admin_user           = "sysadmin"
# ssh_public_key_path  = "~/.ssh/id_ed25519_sysadmin.pub"
enable_auto_shutdown = true   # Deallocate VM every day at 23:00
# vm_sku               = "Standard_B2s" # 4c/4GB
# vm_sku               = "Standard_B1s" # 1c/1GB
allow_ssh_internet = true # Allow SSH access from internet (NSG rule on NIC)
