#!/usr/bin/env bash
set -euo pipefail

# Bootstrap a Kubernetes cluster with Flux and inject SOPS age key as a secret.
# Requires the following environment variables to be set:
# 
# - GITHUB_TOKEN: Personal Access Token with repo permissions
# - AGE_KEY_FILE: Path to the SOPS age key file
# - GITHUB_OWNER: GitHub username or organization
# - GITHUB_REPO: GitHub repository name
# - GITHUB_BRANCH: Branch to use
# - GITHUB_PATH: Path within the repo to the cluster manifests
# - GITHUB_PRIVATE: true if the repo is private, false otherwise
# - GITHUB_PERSONAL: true if using a personal repo
# - GITHUB_INTERVAL: Reconciliation interval (e.g., 1h, 24h)
# - AZURE_CLIENT_ID: Azure Client ID for Key Vault access
# - AZURE_CLIENT_SECRET: Azure Client Secret for Key Vault access

# Default values are set for my homelab repo. Adjust as needed below, or override by exporting env vars.
### --- Defaults
: "${GITHUB_OWNER:=tinoha}"
: "${GITHUB_REPO:=homeit}"
: "${GITHUB_BRANCH:=main}"
: "${GITHUB_PATH:=kubernetes/clusters/home-prod}"
: "${GITHUB_PRIVATE:=true}"
: "${GITHUB_PERSONAL:=true}"
: "${GITHUB_INTERVAL:=24h}"
: "${AGE_KEY_FILE:=$HOME/.config/sops/age/keys.txt}"
: "${AZURE_CLIENT_ID:=}"
: "${AZURE_CLIENT_SECRET:=}"

### --- Pre-checks ---
echo "[*] Checking environment..."

# Check flux CLI
if ! command -v flux >/dev/null 2>&1; then
  echo "❌ flux CLI not found in PATH" >&2
  exit 1
fi

# Check kubectl CLI
if ! command -v kubectl >/dev/null 2>&1; then
  echo "❌ kubectl CLI not found in PATH" >&2
  exit 1
fi

# Check PAT
if [[ -z "${GITHUB_TOKEN:-}" ]]; then
  echo "❌ GITHUB_TOKEN must be exported in the environment" >&2
  exit 1
fi

# Check age key file
if [[ ! -f "$AGE_KEY_FILE" ]]; then
  echo "❌ AGE key file not found: $AGE_KEY_FILE" >&2
  exit 1
fi

# Check Azure credentials
if [[ -z "$AZURE_CLIENT_ID" || -z "$AZURE_CLIENT_SECRET" ]]; then
  echo "❌ AZURE_CLIENT_ID and AZURE_CLIENT_SECRET must be set in the environment" >&2
  exit 1
fi

echo "✅ Environment pre-checks passed."

# Sleep a few seconds to let user read the output
echo "[*] Continuing in 10 seconds... (Ctrl+C to abort)"
sleep 10

### --- Bootstrap ---
echo "[*] Bootstrapping Flux..."

### --- Create flux-system namespace ---
echo "[*] Creating flux-system namespace..."
kubectl create namespace flux-system --dry-run=client -o yaml | kubectl apply -f -

### --- Load age key ---
echo "[*] Injecting SOPS age key into flux-system namespace..."
cat "$AGE_KEY_FILE" | kubectl create secret generic sops-age \
  --from-file=age.agekey=/dev/stdin \
  --namespace=flux-system --dry-run=client -o yaml | kubectl apply -f -

### --- Create external-secrets namespace ---
echo "[*] Creating external-secrets namespace..."
kubectl create namespace external-secrets --dry-run=client -o yaml | kubectl apply -f -

### --- Load Azure Key Vault credentials ---
# # Note: Only ClientID and ClientSecret are injected at bootstrap.
# tenantId and vaultUrl are provided later from the cluster-specific overlay
# (SOPS-encrypted) once external-secrets CRDs are available.
echo "[*] Creating azure-key-vault-secret in external-secrets namespace..."
kubectl -n external-secrets create secret generic azure-key-vault-secret \
  --from-literal=ClientID="${AZURE_CLIENT_ID}" \
  --from-literal=ClientSecret="${AZURE_CLIENT_SECRET}" \
  --dry-run=client -o yaml | kubectl apply -f -

### --- Bootstrap Flux ---
echo "[*] Bootstrapping Flux in the cluster..."

flux bootstrap github \
  --token-auth=false \
  --owner="$GITHUB_OWNER" \
  --repository="$GITHUB_REPO" \
  --branch="$GITHUB_BRANCH" \
  --path="$GITHUB_PATH" \
  --private="$GITHUB_PRIVATE" \
  --personal="$GITHUB_PERSONAL" \
  --interval="$GITHUB_INTERVAL"

echo "✅ Bootstrap complete."
