# main.tf

### Locals ###
locals {
  # Wait seconds after creating role assignments before proceeding with creating resources that depend on those permissions. 
  # RBAC permissions in Azure can take some time to propagate, and without this delay, the subsequent resource creations might fail due to insufficient permissions.
  wait_for_rbac_delay_seconds = 45

  name_base   = "${var.project}-${var.environment}"
  name_suffix = var.name_suffix

  keyvault_name = join("-", compact([
    "kv",
    local.name_base,
    "secrets",
    local.name_suffix
  ]))

  storage_account_name = join("", compact([
    "st",
    var.project,
    var.environment,
    "backup",
    local.name_suffix
  ]))

  # Merge custom tags from variable with default tags below. if there are any overlapping keys, the values from `var.custom_tags` will take precedence.
  merged_tags = merge(
    {
      "environment" = "${var.environment}"
      "project"     = "${var.project}"
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
  resource_group_name = "rg-${local.name_base}-secrets"
  keyvault_name       = local.keyvault_name
  app_name            = "app-${local.name_base}-secrets"
  secrets             = var.load_secrets ? var.secrets : {}

  wait_for_rbac_delay_seconds = local.wait_for_rbac_delay_seconds
  tags                        = local.merged_tags
}

module "backup" {
  source = "../../modules/backup"

  location             = var.location
  resource_group_name  = "rg-${local.name_base}-backup"
  storage_account_name = local.storage_account_name
  app_name             = "app-${local.name_base}-backup"

  wait_for_rbac_delay_seconds = local.wait_for_rbac_delay_seconds
  tags                        = local.merged_tags
  container_names             = local.container_names
}
