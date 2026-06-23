variable "location" {
  description = "The Azure region where the resources will be created."
  type        = string
  default     = "swedencentral"
}

# WARNING:
# Do NOT put real secrets here.
# These values are ONLY placeholders used to pre-create Key Vault secret objects.
# Real secret values MUST be set manually in Azure Key Vault after deployment.
# Terraform state is NOT a safe place for sensitive data.
variable "secrets" {
  description = "List of secret names to pre-populate in the Key Vault with NON-SENSITIVE placeholder values only."
  type        = map(string)
  default = {
    "authentik-db-password"          = "Placeholder value for authentik database password"
    "authentik-db-username"          = "Placeholder value for authentik database username"
    "authentik-secret-key"           = "Placeholder value for authentik secret key"
    "authentik-smtp-password"        = "Placeholder value for authentik SMTP password"
    "authentik-smtp-username"        = "Placeholder value for authentik SMTP username"
    "azure-store-client-id"          = "Placeholder value for backup storage client ID"
    "azure-store-client-secret"      = "Placeholder value for backup storage client secret"
    "azure-tenant-id"                = "Placeholder value for Azure tenant ID"
    "cloudflare-api-token"           = "Placeholder value for cert-manager Cloudflare API token"
    "grafana-cloud-logs-password"    = "Placeholder value for Grafana Cloud logs password"
    "grafana-cloud-logs-username"    = "Placeholder value for Grafana Cloud logs username"
    "grafana-cloud-metrics-password" = "Placeholder value for Grafana Cloud metrics password"
    "grafana-cloud-metrics-username" = "Placeholder value for Grafana Cloud metrics username"
    "pihole-webserver-api-password"  = "Placeholder value for Pi-hole web server API password"
  }
}

variable "custom_tags" {
  description = "A map of custom tags to apply to all resources. These will be merged with default tags defined in the provider configuration."
  type        = map(string)
  default     = {}
}
