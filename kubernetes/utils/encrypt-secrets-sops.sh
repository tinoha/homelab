#!/usr/bin/bash
# Recursively encrypt or decrypt all Kubernetes Secret manifests in the repo using SOPS.
# Looks for any *.yaml or *.yml files under a 'secrets/' directory.

set -euo pipefail

show_help() {
  cat <<EOF
Usage: $(basename "$0") [--encrypt|--decrypt] [--dry-run]

Recursively process all Kubernetes Secret manifests in the repo.

Options:
  --encrypt    Encrypt all matching secrets with SOPS (in-place).
  --decrypt    Decrypt all matching secrets with SOPS (in-place).
  --dry-run    Show which files would be processed, but do not modify them.
  --help       Show this help.

Notes:
- Looks for any *.yaml or *.yml files under a 'secrets/' directory.
- Requires that a valid .sops.yaml policy is present in the repo root or subdirs.
EOF
}

if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]]; then
  show_help
  exit 0
fi

ACTION=""
DRYRUN=false
while [[ $# -gt 0 ]]; do
  case "$1" in
    --encrypt) ACTION="encrypt"; shift ;;
    --decrypt) ACTION="decrypt"; shift ;;
    --dry-run) DRYRUN=true; shift ;;
    *) echo "Unknown option: $1"; show_help; exit 1 ;;
  esac
done

if [[ -z "$ACTION" ]]; then
  echo "Error: must specify --encrypt or --decrypt"
  show_help
  exit 1
fi

# Find all YAML manifests under secrets/ directories
# mapfile -t FILES < <(find . -type f \( -name "*.yaml" -o -name "*.yml" \) -path "*/secrets/*")
mapfile -t FILES < <(find . -type f -regex '.*\.ya?ml' -path '*/secrets/*' -not -regex '.*externalsecret.*\.ya?ml' -not -regex '.*example.*\.ya?ml')

if [[ ${#FILES[@]} -eq 0 ]]; then
  echo "No secret manifests found."
  exit 0
else
  echo "Found ${#FILES[@]} files:"
fi

COUNT=0
for f in "${FILES[@]}"; do
  if [[ "$DRYRUN" == "true" ]]; then
    echo "[DRY-RUN] Would $ACTION $f"
  else
    echo "Processing $f"
    if [[ "$ACTION" == "encrypt" ]]; then
      if grep -q '^sops:' "$f"; then
        echo "Skipping already encrypted file: $f"
        continue
      fi
      sops -e -i "$f"
    else
      sops -d -i "$f"
    fi
  fi
  COUNT=$((COUNT + 1))
done

echo "Done. $COUNT files processed."
