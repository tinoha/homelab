# Homelab Kubernetes Services Deployment Instructions


- Helm commands needed to add repositories and install/update the core services (Metallb, Kong, Cert-Manager)
- Deploy services/apps with Kustomize. 

## Prerequisites
NOTE: Install required CRDS first.

k apply -f crds/

## 1. Add Helm Repositories
helm repo add metallb https://metallb.github.io/metallb --force-update
helm repo add kong https://charts.konghq.com --force-update
helm repo add jetstack https://charts.jetstack.io --force-update
helm repo update

## 2. Install / Upgrade Services with Helm

### Metallb
helm upgrade --install metallb metallb/metallb \
  --namespace metallb-system \
  --create-namespace

### Kong Ingress
helm upgrade --install kong kong/ingress \
  --namespace kong \
  --create-namespace

### Cert-Manager
helm upgrade --install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --version v1.17.2 \
  --set crds.enabled=true

### Verify Deployments
kubectl get pods -n metallb-system
kubectl get pods -n kong
kubectl get pods -n cert-manager

## 3. Deploy Apps/Services with Kustomize

### Dry-run to preview manifests:
kubectl kustomize .
kubectl apply -k . --dry-run=client 

### Apply all application manifests
kubectl apply -k .


## 4 Verify All Deployments

### Check Helm releases
helm list -A

### Check running pods
kubectl get pods -A

Check Services
###kubectl get svc -A
