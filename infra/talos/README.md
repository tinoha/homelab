# Talos Cluster Setup (home-prod)

This document describes how the `home-prod` *Talos cluster* is built.  
It is **not a generic Talos installation guide** — steps are tailored to this repository’s structure and configuration.  

If you want to replicate or adapt this setup:
- Review and edit patch files under `patches/` (e.g., `talos-prod-1-patch.yaml`, `user-volume-patch.yaml`, `tailscale-patch.yaml`).
- Adjust variables (VM names, IP addresses, domain, cluster name, etc.) to match your environment.

## 1. Install talosctl client
```bash
curl -sL https://talos.dev/install | sh
```
## 2. Obtain Talos installation image
Two image types and download methods explained on this chapter:
- QCOW2 image — prebuilt image for virtual machines
- ISO image — for initial boot on bare metal or virtual machines

You can:
- Visit https://factory.talos.dev and download images directly, or
- Build and download the image manually using schematics file as shown below.

Get the customization id based on the schematic file.
```bash
cd infra/talos
curl -X POST --data-binary @customization-schematic.yaml  https://factory.talos.dev/schematics 
```
List available versions (latest 20 shown):
```bash
curl -s https://factory.talos.dev/versions | yq | tail -20
```
Download the image (example: Talos v1.11.3). Below are the options for both prebuilt images and iso initial boot images. Choose the image type that suits your needs:
```bash
curl -LO  https://factory.talos.dev/image/\<schematic_id\>/v1.11.3/metal-amd64.qcow2   # QCOW2 prebuilt image for virtual machine 
curl -LO  https://factory.talos.dev/image/\<schematic_id\>/v1.11.3/metal-amd64.iso     # ISO image for bare metal or virtual machine initial boot
```
## 3. Install Talos on a KVM/Libvirt Virtual Machine
This example creates a single-node Talos cluster (`home-prod-cl`) on an Ubuntu Libvirt/QEMU/KVM host.

Set environment variables
```bash 
export vm_name="talos-prod-1"                                     # Name of the VM
export disk_path="/data/vm-disks"                                 # Disk path to images
```

### Option A: Create a Talos VM using a prebuilt QCOW2 image
Create data disk image and copy the downloaded OS image
```bash
qemu-img create -f qcow2 ${disk_path}/${vm_name}-d1.qcow2 10G   # Create user data disk
cp metal-amd64.qcow2 ${disk_path}/${vm_name}.qcow2              # Copy the OS image in place
```

Create Talos VM
```bash
virt-install \
  --virt-type kvm \
  --name ${vm_name} \
  --memory 7000 \
  --vcpus 2,sockets=1,cores=2,threads=1 \
  --disk path=${disk_path}/${vm_name}.qcow2,format=qcow2,bus=virtio \
  --disk path=${disk_path}/${vm_name}-d1.qcow2,format=qcow2,bus=virtio \
  --import \
  --os-variant linux2024 \
  --network bridge=br0,model=virtio \
  --boot hd,cdrom --noautoconsole \
  --cpu host-passthrough \
  --machine q35 \
  --boot loader=/usr/share/OVMF/OVMF_CODE_4M.fd,loader.readonly=yes,loader.type=pflash,nvram.template=/usr/share/OVMF/OVMF_VARS_4M.fd \
  --tpm emulator
  ```

Extend the Talos system disk size. Check disk name — in this example it's `vda`.
```bash
  virsh domblklist ${vm_name}
  virsh blockresize ${vm_name} vda 20G 
```
Retrieve the newly created Talos VM IP address and export it. 
 ```bash
 export CP_IP="x.x.x.x" # Control plane node IP address
``` 

### Option B: Create a Talos VM using an ISO image
Create data disk image and copy the downloaded OS image
```bash
qemu-img create -f qcow2 ${disk_path}/${vm_name}-d1.qcow2 10G     # Create user data disk
cp metal-amd64.iso ${disk_path}/                                  # Copy the ISO image in place
```
Create Talos VM
```bash
virt-install \
  --virt-type kvm \
  --name ${vm_name} \
  --memory 7000 \
  --vcpus 2,sockets=1,cores=2,threads=1 \
  --disk pool=vm-disks,size=25,format=qcow2,bus=virtio \
  --disk path=${disk_path}/${vm_name}-d1.qcow2,format=qcow2,bus=virtio \
  --cdrom /data/vm-disks/metal-amd64.iso \
  --os-variant linux2024 \
  --network bridge=br0,model=virtio \
  --boot hd,cdrom --noautoconsole \
  --cpu host-passthrough \
  --machine q35 \
  --boot loader=/usr/share/OVMF/OVMF_CODE_4M.fd,loader.readonly=yes,loader.type=pflash,nvram.template=/usr/share/OVMF/OVMF_VARS_4M.fd \
  --tpm emulator
  ```

Retrieve and export the VM’s IP address:
 ```bash
 export CP_IP="x.x.x.x" # Control plane node IP address
```

## 4. Generate secrets and configurations
Generate cluster secrets. (Store securely):
```bash
talosctl gen secrets --output-file secrets/secrets.yaml
```

Generate a control plane configuration (edit patch files as needed):
```bash
 talosctl gen config home-prod-cl https://kube.home.example.com:6443 \
    --with-secrets secrets/secrets.yaml \
    --output-types  controlplane \
    --config-patch-control-plane @patches/${vm_name}-patch.yaml \
    --config-patch @patches/user-volume-patch.yaml \
    --config-patch @secrets/tailscale-patch.yaml \
    --output configs/${vm_name}.yaml
```

## 5. Apply configuration to the control plane node
```bash
talosctl apply --nodes ${CP_IP}  \
  --file configs/${vm_name}.yaml \
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

## 7. Access and verify the Talos node
Prepare `talosconfig` file for accessing the cluster. Set the `CP_IP` variable to the real permanent IP.
```bash
export CP_IP="x.x.x.x"                            # Real permanent IP
export TALOSCONFIG="${PWD}/configs/talosconfig"   # set path to talosconfig
talosctl config endpoint ${CP_IP}                 # Set endpoint to current Talos node ip.
talosctl config merge                             # Optional: merge config to default path 
talosctl -n ${CP_IP} dashboard                    # Check node status and access  
```
## 8. Bootstrap the Kubernetes control plane
After the Talos node is configured and reachable, initialize the Kubernetes control plane:
```bash
talosctl -n ${CP_IP} bootstrap 
```

## 9. Verify cluster health (and remove CDROM)
Use talosctl to check cluster and node status.
```bash
talosctl  -n ${CP_IP} dashboard                                
talosctl  -n ${CP_IP} health

talosctl get rd # To see all resources to query
```

Remember also to remove CDROM if you used an ISO image for installation.
```bash
virsh domblklist ${vm_name}               # Check cdrom disk name
virsh detach-disk ${vm_name} sda --config # Remove cdrom disk (assuming it's name is`sda`)
```

## 10. Generate and use kubeconfig
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