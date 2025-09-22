## Kubernetes Cluster Bootstrap with Flux

This repository contains scripts to bootstrap and manage a Kubernetes cluster using:

- **Flux** (GitOps operator)
- **SOPS / age** (for secrets management)
- **External Secrets Operator (ESO)**

> ⚠️ This guide is specific to `bootstrap.sh` and assumes you have privileged access to the cluster. It is **not a general Flux tutorial**.

---

## Prerequisites

Before running the bootstrap, ensure you have:

- A Kubernetes cluster with admin privileges  
- Installed locally:
  - [kubectl](https://kubernetes.io/docs/tasks/tools/)
  - [Flux CLI](https://fluxcd.io/flux/installation/)
  - [SOPS](https://github.com/getsops/sops)
  - [age](https://github.com/FiloSottile/age)

---

## Step 1: Prepare SOPS Age Key (First-Time Only)

If this is the **first time** you are bootstrapping a cluster/environment, you need an **age key** to encrypt secrets:

```bash
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt

export AGE_KEY_FILE=~/.config/sops/age/keys.txt
```

## Step 2: Configure GitHub Access
The bootstrap script requires several environment variables for GitHub integration. In GitHub, generate a fine-grained PAT token with permissions:

- Administration -> Access: Read and write
- Contents -> Access: Read and write
- Metadata -> Access: Read-only

`flux github ...` needs PAT token to commit the flux manifests to the repo and to set-up a ssh key for further connections. PAT token is not used once cluster is up and running (see option --token-auth=false) 

Next, export variables in your shell, or edit directly into the script:

```bash 
export GITHUB_TOKEN=<your_personal_access_token>          # PAT token with repo permissions
export GITHUB_OWNER=<github_username_or_org>
export GITHUB_REPO=<repository_name>
export GITHUB_BRANCH=<branch_to_use>
export GITHUB_PATH=<path_to_cluster_manifests>
export GITHUB_PRIVATE=<true|false>                        # true if the repo is private
export GITHUB_PERSONAL=<true|false>                       # true if using a personal repo
export GITHUB_INTERVAL=<reconciliation_interval>          # e.g., 1h, 24h
```

## Step 3: Configure Azure Key Vault Access
Ensure your Azure Key Vault is configured and accessible. You’ll need valid credentials to authenticate and retrieve secrets during bootstrap.
```bash
export AZURE_CLIENT_ID="<your_azure_client_id>"           # Azure Client ID for Key Vault access
export AZURE_CLIENT_SECRET="your_azure_client_secret"     # Azure Client Secret for Key Vault access
```

Note: Only Azure Vault ClientID and ClientSecret are injected at bootstrap. To access Azure Vault you also need 
tenantId and vaultUrl. These variable are loaded later from the cluster-specific overlay (SOPS-encrypted) once external-secrets CRDs are available. These variables are located in file:
`./infrastructure/configs/home-prod/secrets/patch-azure-clustersecretstore.yaml`

## Step 4: Bootrap the Cluster with flux
Ensure your `kubectl config`  points to the correct Kubernetes cluster.
```
kubectl config get-contexts
kubectl get nodes

Finally, run the script to initialize Flux and cluster
```bash
./bootstrap.sh
```
The script will:
- Install Flux components into the cluster
- Commit Flux manifests to the repository
- Trigger an initial sync of the cluster with the repository

## Verify Bootstap

Here are some commands to check flux is running and resources are being deployed:
```bash
flux check
flux get kustomizations
flux get all

kubectl get clustersecretstore,externalsecret -A # Check ESO status
kubectl get all -A # Show resources...
