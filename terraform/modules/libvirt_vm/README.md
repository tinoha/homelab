# libvirt_vm Module

Provision virtual machines (VMs) using the Libvirt provider in Terraform.

## Variables

| Variable                 | Description                          | Type   | Default                                                               |
| ------------------------ | ------------------------------------ | ------ | --------------------------------------------------------------------- |
| `libvirt_uri`            | URI for the libvirt provider.        | string | `qemu:///system`                                                      |
| `image_source`           | Base image source URL.               | string | `https://cloud-images.ubuntu.com/.../noble-server-cloudimg-amd64.img` |
| `volume_pool`            | Volume pool name.                    | string | `default`                                                             |
| `vm_name`                | Base name for VMs.                   | string | `tfvm`                                                                |
| `vm_count`               | Number of VMs to create.             | number | `1`                                                                   |
| `vm_vcpu`                | Number of vCPUs per VM.              | number | `2`                                                                   |
| `vm_memory`              | Amount of memory per VM in MB.       | number | `4096`                                                                |
| `vm_cpu_mode`            | CPU mode for the VM.                 | string | `host-passthrough`                                                    |
| `vm_qemu_agent`          | Enable QEMU agent.                   | bool   | `false`                                                               |
| `network_wait_for_lease` | Wait for network address assignment. | bool   | `false`                                                               |
| `vm_disk_scsi`           | Use SCSI for the disk.               | bool   | `true`                                                                |
| `network_bridge`         | Network bridge for the VM.           | string | `br0`                                                                 |
| `cloudinit_name`         | Cloud-init volume name.              | string | `cloudinit-common.iso`                                                |
| `cloudinit_pool`         | Pool name for the cloud-init volume. | string | `default`                                                             |
| `cloud_init_data_file`   | Path to the user-data file.          | string | `null`                                                                |

## Outputs

| Output            | Description                                     |
| ----------------- | ----------------------------------------------- |
| `vm_ip_addresses` | List of IP addresses of all VMs, if applicable. |

## Example Usage

```hcl
module "libvirt_vm" {
  source = "./libvirt_vm"

  libvirt_uri          = "qemu:///system"
  image_source         = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  volume_pool          = "default"
  vm_name              = "my-vm"
  vm_count             = 1
  vm_vcpu              = 2
  vm_memory            = 4096
  vm_cpu_mode          = "host-passthrough"
  vm_qemu_agent        = true
  network_wait_for_lease = true
  vm_disk_scsi         = true
  network_bridge       = "br0"
  cloudinit_name       = "cloudinit-common.iso"
  cloudinit_pool       = "default"

  # Cloud-init specific variables
  username             = "admin"
  gecos                = "Administrator"
  groups               = "sudo"
  shell                = "/bin/bash"
  ssh_key              = "<SSH_PUBLIC_KEY>"
  sudo_privileges      = "ALL=(ALL) NOPASSWD:ALL"
  ssh_pwauth           = "true"
  password             = "<DEFAULT_PASSWORD>"
}
```
