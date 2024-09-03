# VM creation
libvirt_uri = "qemu:///system"

volume_pool            = "Images-lvm-fs"
cloudinit_pool         = "Images-lvm-fs"
image_source           = "/tmp/noble-server-cloudimg-amd64.img"
vm_name                = "kube" # Base name for the vm's
vm_count               = 2
vm_vcpu                = 2
vm_memory              = 4096 # 4GB
vm_qemu_agent          = true
network_bridge         = "br0"
network_wait_for_lease = true

# VMs cloud-init config
username        = "sysadmin"
gecos           = "System Administrator"
groups          = "sudo"
shell           = "/bin/bash"
ssh_key         = "~/.ssh/id_ed25519_sysadmin.pub"
sudo_privileges = "ALL=(ALL) NOPASSWD:ALL"
ssh_pwauth      = ""
password        = ""
