# Azure Infrastructure Setup with Terraform

`./infra/terraform/`

This directory contains the Terraform configuration used to provision the Azure resources required by the homelab platform.

## Overview
The current implementation provisions:

- **Azure Storage Account**: Used as a backup target for the CloudNativePG/BarmanCloud plugin.
- **Azure Key Vault**: Used as the backend for the External Secrets Operator.
- **Microsoft Entra ID**: Application registrations and service principals used by Kubernetes workloads.
- **Azure RBAC**: Role assignments required for resource access and management.

Terraform is intentionally separated from the Kubernetes GitOps configuration. Cloud resources are provisioned first, after which Kubernetes components consume them via workload-specific credentials.

### Directory Structure
```bash
terraform/
├── bootstrap/      # Creates remote Terraform state storage 
├── environments/   # Environment-specific deployments          
├── modules/        # Reusable Terraform modules (e.g., backup and secrets)
└── scripts/        # Utility and helper scripts 
```

## Prerequisites

Before provisioning Azure resources, ensure the following requirements are met:

- An active [Azure subscription](https://azure.microsoft.com/en-us/free/).
- The following tools installed locally:
  - [Terraform](https://developer.hashicorp.com/terraform/install)
  - [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) *)
- **Naming**: Azure Storage Account and Key Vault names must be globally unique.

\*) Alternatively, you may use the wrapper script under `scripts/az` that runs the Azure CLI inside a Podman container. Copy it under `/usr/local/bin` to use it (podman required).

## Authenticate with Azure
The deployment account must have sufficient permissions to:
- Create resource groups, storage accounts, and Key Vaults.
- Create Microsoft Entra ID applications and service principals.
- Assign Azure RBAC roles to self and to created service principals. 

This deployment uses Azure RBAC for authorization. Shared access keys and legacy access policies are disabled where supported.

Authenticate using the Azure CLI:
```bash
az login 
az account list -o table
az account set --subscription "<subscription-id>"
```

## Bootstrap Terraform State Backend

The bootstrap configuration is used only to create the Storage Account for the Terraform remote state. This bootstrap phase uses a local filesystem state.

1. **Prepare variables**: Copy the template variable file and set the `project` and optionally `suffix` variables. Be mindful of Azure storage account naming restrictions (lowercase, alphanumeric).
```bash
cd ./infra/terraform/bootstrap
cp ./terraform.tfvars.example ./terraform.tfvars
# Edit the variables in the file...
```

2. **Deploy**:
```bash
terraform init      # Initialize Terraform
terraform plan      # Preview changes
terraform apply     # Apply the configuration
```

3. **Retrieve Output**: This information is required to configure the backend for the environment deployments.
```bash
terraform output
```

## Deploy Azure Resources

This section describes the deployment of the `prod` environment located at `./infra/terraform/environments/prod/`.

1. **Prepare Terraform backend config**: Copy backend.conf.example to backend.conf, then replace the placeholder values with the outputs from the bootstrap deployment (terraform output).
```bash
cd ./infra/terraform/environments/prod
cp backend.conf.example backend.conf

# Edit backend.conf to include ONLY the missing infrastructure parameters:
resource_group_name  = "<resource_group_name>"
storage_account_name = "<storage_account_name>"
container_name       = "<container_name>"
```

2. **Initialize Terraform backend**: This merges your local backend.conf parameters with the default settings defined in backend.tf.
```bash
terraform init -backend-config=backend.conf
```

3. **Prepare variables**: Copy the template variable file and edit `project` and `suffix`. Use only lowercase alphanumeric characters for storage account names.
```bash
cp ./terraform.tfvars.example ./terraform.tfvars
# Edit the variables in the file...
```

4. **Secrets Initialization (Optional)**: To load placeholder secrets into the Key Vault, set `load_secrets = true` in `./terraform.tfvars`. You can update these with real values later via the Azure Portal or CLI.

5. **Deploy**:
```bash
terraform plan      # Preview changes
terraform apply     # Apply the configuration
```

6. **Retrieve Output**:
```bash
terraform output
```

## Final Tasks

Perform these steps to enable Kubernetes workloads to connect to the Azure resources.

### Service Principal Credentials
Reset the Azure service principal passwords (`client_secret`) and record them for Kubernetes configuration. Use the `client_id` for backup and keyvault service principals from the `terraform output`. **Note: Credentials are shown only once during creation.**
```bash 
az ad app credential reset --id <client_id>
```

### How to Manage Key Vault Secrets
To update placeholder secrets with real values, you may use the following Azure CLI commands or do it via the Azure portal. 

**List all secrets and their placeholder values:**
```bash
export KV="<your_kv_name>"
az keyvault secret list --vault-name $KV --query [].name -o tsv > secret_names.txt
for secret in $(cat ./secret_names.txt); do 
  value=$(az keyvault secret show --vault-name $KV --name $secret --query value -o tsv)
  echo "${secret} ${value}"
done
```

**Set a secret to a new value:**
```bash
az keyvault secret set --vault-name $KV --name "<secret_name>" --value "secret_value"
```

## Destroy Azure Resources

**⚠️ WARNING: This action will permanently delete all Azure resources provisioned during this setup. This process is irreversible.**

To completely remove the infrastructure, you must destroy the resources in the reverse order of creation to ensure the Terraform state remains accessible.

**Destroy the Environment Deployment**: First, remove the environment-specific resources (e.g., `prod`).
```bash
cd ./infra/terraform/environments/prod
terraform destroy
```

**Destroy the Bootstrap Backend**: Only after the environment resources are deleted should you remove the remote state storage account.
```bash
cd ./infra/terraform/bootstrap
terraform destroy
```
