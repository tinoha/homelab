provider "libvirt" {
  # Configuration options
  uri = var.libvirt_uri
}

locals {
  image_name = element(regex("([^/]+)$", var.image_source), 0)
  # Create VM info array for output.
  vm_info = [
      for vm in libvirt_domain.vm[*] : {
        name       = vm.name
        private_ip = length(vm.network_interface[0].addresses) > 0 ? vm.network_interface[0].addresses[0] : ""  # Check if the list is not empty
        id         = vm.id
      }
    ]
}

resource "libvirt_volume" "os_base" {
  name   = local.image_name
  source = var.image_source
  pool   = var.volume_pool
}

resource "libvirt_volume" "os" {
  count          = var.vm_count
  name           = "${var.vm_name}-${count.index+1}.qcow2"
  base_volume_id = libvirt_volume.os_base.id
  pool           = var.volume_pool
  size           = var.os_volume_size
}

resource "libvirt_domain" "vm" {
  count  = var.vm_count
  name   = "${var.vm_name}-${count.index+1}"
  vcpu   = var.vm_vcpu
  memory = var.vm_memory
  #machine = "pc-q35-8.2"  # if defined cloudinit_disk fails as IDE not supported
  qemu_agent = var.vm_qemu_agent
  cloudinit = libvirt_cloudinit_disk.common[count.index].id

  cpu {
    mode = var.vm_cpu_mode
  }

  disk {
    volume_id = libvirt_volume.os[count.index].id
    scsi      = var.vm_disk_scsi
  }

  network_interface {
    bridge = var.network_bridge
    wait_for_lease = var.network_wait_for_lease
  }

  # Ensure changes to the WWN are ignored
  lifecycle {
    ignore_changes = [
      disk[0].wwn
    ]
  }
}

resource "libvirt_cloudinit_disk" "common" {
  count  = var.vm_count
  name      = "${var.cloudinit_name}-${count.index+1}.iso"
  pool      = var.cloudinit_pool
  #user_data = module.cloud-init.user_data_txt
  user_data = module.cloud-init[count.index].user_data_mime
}
  
module "cloud-init" {
  source = "../cloud-init"

  count           = var.vm_count
  username        = var.username
  data_file       = var.data_file
  gecos           = var.gecos
  groups          = var.groups
  shell           = var.shell
  ssh_key         = file(var.ssh_key)
  sudo_privileges = var.sudo_privileges
  ssh_pwauth      = var.ssh_pwauth
  password        = var.password
  hostname = "${var.vm_name}-${count.index+1}"  # Set VM hostname 
}

