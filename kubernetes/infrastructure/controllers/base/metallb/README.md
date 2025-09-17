# Metallb Setup

Metallb is intentionally split into two separate Kustomizations:

1. **metallb-controller**  
   - Installs the Helm chart (CRDs + controller deployment).  
   - Provides the core functionality and API definitions.

2. **metallb-configs**  
   - Applies CRs such as `IPAddressPool` and `L2Advertisement`.  
   - These require the CRDs installed by the controller to exist first.

## Why this split is necessary

Flux (and Kubernetes in general) cannot apply custom resources (CRs) before the corresponding CRDs exist.  
If both controller and configs are applied together, reconciliation will fail or loop endlessly.  

Therefore, `metallb-configs` explicitly **depends on** `metallb-controller`. This ensures the controller (and its CRDs) are ready before configs are applied.
These kustomization are defined in overlay side.
