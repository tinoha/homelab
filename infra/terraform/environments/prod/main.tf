# main.tf

### Locals ###
locals {
  # Wait seconds after creating role assignments before proceeding with creating resources that depend on those permissions. 
  # RBAC permissions in Azure can take some time to propagate, and without this delay, the subsequent resource creations might fail due to insufficient permissions.
  wait_for_rbac_delay_seconds = 45

  # Set the params for this configuration. These are used for tagging and naming resources.
  project     = "hlab"
  environment = "prod"

  name_prefix = "${local.project}-${local.environment}"

  # Merge custom tags from variable with default tags below. if there are any overlapping keys, the values from `var.custom_tags` will take precedence.
  merged_tags = merge(
    {
      "environment" = "${local.environment}"
      "project"     = "${local.project}"
      "managed-by"  = "terraform"
    },
    var.custom_tags
  )

  container_names = [
    "dev-pg-backups",  # PostgreSQL backup buckets used by CNPG/Barman (dev)
    "prod-pg-backups", # PostgreSQL backup buckets used by CNPG/Barman (prod)
  ]
}

# All Azure resources use: <type>-<workload>-<env>-<component>
# Storage accounts use: st<workload><env><component> (no hyphens, lowercase only)

# Create keyvault and service principal.
# Uncomment secrets parameter to load placeholder secrets used in this homelab.
module "secrets" {
  source = "../../modules/secrets"

  location            = var.location
  resource_group_name = "rg-${local.name_prefix}-secrets"
  keyvault_name       = "kv-${local.name_prefix}-secrets"
  app_name            = "app-${local.name_prefix}-secrets"
  # secrets             = var.secrets 

  wait_for_rbac_delay_seconds = local.wait_for_rbac_delay_seconds
  tags                        = local.merged_tags
}

module "backup" {
  source = "../../modules/backup"

  location             = var.location
  resource_group_name  = "rg-${local.name_prefix}-backup"
  storage_account_name = "st${local.project}${local.environment}backup"
  app_name             = "app-${local.name_prefix}-backup"

  wait_for_rbac_delay_seconds = local.wait_for_rbac_delay_seconds
  tags                        = local.merged_tags
  container_names             = local.container_names
}
