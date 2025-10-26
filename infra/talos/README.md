# Talos Cluster Setup (home-prod)

This document describes how *the `home-prod` Talos cluster* is built.  
It is **not a generic Talos installation guide** — steps are tailored to this repository’s structure and configuration.  

If you want to replicate or adapt this setup:
- Review and edit patch files under `patches/` (e.g., `talos-prod-1-patch.yaml`, `user-volume-patch.yaml`, `tailscale-patch.yaml`).
- Adjust variables (VM names, IP addresses, domain, cluster name, etc.) to match your environment.
- Never commit `secrets.yaml` or other sensitive files to Git.


## 1. Install talosctl client
```bash
curl -sL https://talos.dev/install | sh
```
## 2. Obtain Talos installation image
You can either download prebuilt image, optionally customized with a schematic file, or you may download the ISO image for initial boot on bare metal or virtual machine. Below is the manual process of downloading the prebuilt image with schematics but you may also download the image directly from talos image factory

Option A: Build from Schematic

Get the customization id based on the schematic file.
```bash
cd infra/talos
curl -X POST --data-binary @customization-schematic.yaml  https://factory.talos.dev/schematics 
```
List available versions (latest 20 shown):
```bash
curl -s https://factory.talos.dev/versions | yq | tail -20
```
Download the prebuilt qcow2 image (example: Talos v1.11.3).   :
```bash
curl -LO  https://factory.talos.dev/image/\<schematic_id\>/v1.11.3/metal-amd64.qcow2   # QCOW2 prebuilt image for virtual machine 
# curl -LO  https://factory.talos.dev/image/\<schematic_id\>/v1.11.3/metal-amd64.iso   # ISO image for bare metal or virtual machine initial boot

```
Option B: Download from Image Factory

Visit https://factory.talos.dev and download a ready-made image directly.

## 3. Install Talos on a KVM/Libvirt Virtual Machine
This example creates a single-node Talos cluster (talos-prod-1) on an Ubuntu host running Libvirt/QEMU/KVM.

Set environment variables
```bash 
export vm_name="talos-prod-1"                                     # Name of the VM
export disk_path="/data/vm-disks"                                 # Disk path to images
```

Create data disk image and copy the downloaded OS image
```bash
qemu-img create -f qcow2 ${disk_path}/talos-prod-1-d1.qcow2 10G   # Create user data disk
cp metal-amd64.qcow2 ${disk_path}/talos-prod-1.qcow2              # Copy the OS image in place
```

Create and import the Talos VM
```bash
virt-install \
  --virt-type kvm \
  --name ${vm_name} \
  --memory 7000 \
  --vcpus 2 \
  --disk path=${disk_path}/${vm_name}.qcow2,format=qcow2,bus=virtio \
  --disk path=${disk_path}/${vm_name}-d1.qcow2,format=qcow2,bus=virtio \
  --import \
  --os-variant linux2024 \
  --network bridge=br0,model=virtio \
  --boot hd,cdrom --noautoconsole \
  --cpu host-passthrough \
  --machine q35 \
  --console pty,target_type=virtio \
  --graphics none
  ```
<!--
   --disk pool=vm-disks,size=20,format=qcow2,bus=virtio \  # Create image dynamically during vm creation from given pool
   --cdrom ${talos_iso} \  # in case using ISO image for initial boot
   --boot loader=/usr/share/OVMF/OVMF_CODE_4M.fd,loader.readonly=yes,loader.type=pflash,nvram.template=/usr/share/OVMF/OVMF_VARS_4M.fd  # For using EFI boot loader, w/o secure boot
 -->
 
 ## 4. Initial Configuration
 Find the newly created Talos VM IP address and put it to a variable. 
 ```bash
 export CP_IP="x.x.x.x" # Control plane node IP address
```

 Extend the Talos system volume size. Check volume name — in this example it's `vda`.
```bash
  virsh domblklist ${vm_name}
  virsh blockresize ${vm_name} vda 20G 
```
## 5. Generate secrets and configurations
Generate cluster secrets. Keep file safe and secure.
```bash
talosctl gen secrets --output-file secrets/secrets.yaml
```

Create a config file for the control plane. Before running the command, check the patch files and edit as needed.
 ```bash
 talosctl gen config home-prod-cl https://kube.home.example.com:6443 \
    --with-secrets secrets/secrets.yaml \
    --output-types  controlplane \
    --config-patch-control-plane @patches/talos-prod-1-patch.yaml \
    --config-patch @patches/user-volume-patch.yaml \
    --output configs/talos-prod-1.yaml
    
```

Apply config to the Talos controlplane node.
```bash
talosctl apply --nodes ${CP_IP}  \
  --file configs/talos-prod-1.yaml \
  --config-patch @secrets/tailscale-patch.yaml \
  --mode=reboot --insecure
```

## 6. Generate Talos API configuration
Generate Talos API configuration so that the newly created controlplane can be accessed with `talosctl`.
```bash
 talosctl gen config home-prod-cl https://kube.home.example.com:6443 \
    --with-secrets secrets/secrets.yaml \
    --output-types  talosconfig \
    --output configs/talosconfig
```

## 7. Access and verify the cluster node.
```bash
export CP_IP="x.x.x.x"                            # Reset to the real permanent IP
export TALOSCONFIG="${PWD}/configs/talosconfig"   # set path to talosconfig
talosctl config endpoint ${CP_IP}                 # Set endpoint to current Talos node ip.
talosctl config merge                             # Optional: merge config to default path 
talosctl dashboard                                # Check node status 
```

## 8. Bootstrap the Kubernetes cluster
After the Talos node is configured and reachable, initialize the Kubernetes control plane:
```bash
talosctl bootstrap 
```

## 9. Verify the cluster state
Use talosctl to check cluster and node status.
```bash
talosctl dashboard                                
talosctl health
talosctl get nodestatus
talosctl get disks
talosctl get ethernetstatus

talosctl get rd # To se all resources to query
```

## 10. Generate kubeconfig and access the cluster
Once the bootstrap process completes successfully, generate the kubeconfig file for accessing the Kubernetes API with kubectl. 

```bash
talosctl kubeconfig configs/kubeconfig
export KUBECONFIG="${PWD}/configs/kubeconfig"

```

Verify access to the cluster
```bash
kubectl get nodes -o wide
kubectl describe nodes
```

✅ At this point, the Talos-managed Kubernetes control plane is up and running.
You can proceed with GitOps bootstrap (e.g., FluxCD) or start deploying workloads.   