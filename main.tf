provider "libvirt" {
  # Configuration options
  uri = var.libvirt_uri
}

locals {
  image_name = element(regex("([^/]+)$", var.image_source), 0)
}

resource "libvirt_volume" "os_base" {
  name   = local.image_name
  source = var.image_source
  pool   = var.volume_pool
}

resource "libvirt_volume" "os" {
  name           = "${var.vm_name}.qcow2"
  base_volume_id = libvirt_volume.os_base.id
  pool           = var.volume_pool
}

resource "libvirt_domain" "vm" {
  name   = var.vm_name
  vcpu   = var.vm_vcpu
  memory = var.vm_memory
  #machine = "pc-q35-8.2"  # if defined cloudinit_disk will fails as IDE not supported
  #qemu_agent = "true"
  cloudinit = libvirt_cloudinit_disk.common.id

  cpu {
    mode = var.vm_cpu_mode
  }

  disk {
    volume_id = libvirt_volume.os.id
    scsi      = var.vm_disk_scsi
  }

  network_interface {
    bridge = var.network_bridge
  }
  
  # Ensure changes to the WWN are ignored
  lifecycle {
    ignore_changes = [
      disk[0].wwn
    ]
  }
}

resource "libvirt_cloudinit_disk" "common" {
  name      = var.cloudinit_name
  pool      = var.cloudinit_pool
  user_data = data.template_file.cloud_init_user_data.rendered
}

data "template_file" "cloud_init_user_data" {
  template = file(local.cloud_init_data_file)
}

locals {
  cloud_init_data_file = var.cloud_init_data_file == null ? "${path.module}/cloud-init/user-data" : var.cloud_init_data_file
}

