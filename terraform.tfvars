# VM definitions for Ubuntu. 
volume_pool    = "Images-lvm-fs"
cloudinit_pool = "Images-lvm-fs"

image_source   = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
vm_name        = "tfvm"
vm_vcpu        = "2"
vm_memory      = "4096"
network_bridge = "br0"
#cloud_init_data_file = "" 

