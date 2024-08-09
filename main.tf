provider "libvirt" {
  # Configuration options
  uri = "qemu:///system"
}

resource "libvirt_volume" "ubuntu-noble-base" {
  name  = "noble-server-cloudimg-amd64.img"
  source = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  pool   = "Images-lvm-fs"
}

resource "libvirt_volume" "osdisk" {
  name = "terraform-1-os.qcow2"
  base_volume_id  = libvirt_volume.ubuntu-noble-base.id
  pool = "Images-lvm-fs"
}

resource "libvirt_domain" "ubuntu" {
  name = "terraform-1"
  vcpu = "2"
  memory = "4096"
  #machine = "pc-q35-8.2"
  #qemu_agent = "true"
  cloudinit = libvirt_cloudinit_disk.commoninit.id

  cpu {
    mode = "host-passthrough"
  }

  disk {
    volume_id = libvirt_volume.osdisk.id
    scsi = "true"
  }
  
  network_interface {
    bridge = "br0"
  }
}


resource "libvirt_cloudinit_disk" "commoninit" {
  name  = "cloudinit-common.iso"
  pool  = "Images"
  user_data = data.template_file.user_data.rendered
}

data "template_file" "user_data" {
  template = file("${path.module}/cloud-init/user-data")
}