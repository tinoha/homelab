variable "libvirt_uri" {
  description = "The URI for the libvirt provider."
  type        = string
  default     = "qemu:///system"
}

variable "image_source" {
  description = "The source for the base image."
  type        = string
  default     = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}


variable "volume_pool" {
  description = "The name of the pool for the volumes."
  type        = string
  default     = "default"
}

variable "vm_name" {
  description = "The name of the vm."
  type        = string
  default     = "tfvm"
}

variable "vm_count" {
  description = "The number of vm's created "
  type        = number
  default     = 1
}

variable "vm_vcpu" {
  description = "The number of vCPUs for the vm."
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "The amount of memory (in MB) for the vm."
  type        = number
  default     = 4096
}

variable "vm_cpu_mode" {
  description = "The CPU mode for the vm."
  type        = string
  default     = "host-passthrough"
}

variable "vm_qemu_agent" {
  description = "Use QEMU agent: true|false "
  type        = bool
  default     = false
}

variable "network_wait_for_lease" {
  description = "Wait address is assigned to the interface: true|false. If you enable this, then set also vm_qemu_agent = true."
  type        = bool
  default     = false
}

variable "vm_disk_scsi" {
  description = "Whether the disk should use SCSI."
  type        = bool
  default     = true
}

variable "network_bridge" {
  description = "The network bridge for the vm."
  type        = string
  default     = "br0"
}

variable "cloudinit_name" {
  description = "The name of the cloudinit volume."
  type        = string
  default     = "cloudinit-common.iso"
}

variable "cloudinit_pool" {
  description = "The pool name for the cloudinit volume."
  type        = string
  default     = "default"
}

###### Cloud-init module variables

variable "data_file" {
  description = "Path to a cloud-init user-data file with static values (no templating). When set all  When not set the default template and will be used."
  type        = string
}

### user-data users: section variables ###
variable "username" {
  description = "User name in cloud-init"
  type        = string
}

variable "gecos" {
  description = "User description in cloud-init"
  type        = string
}

variable "groups" {
  description = "Groups of the user in cloud-init"
  type        = string
}

variable "shell" {
  description = "Shell for the user in cloud-init"
  type        = string
}

variable "ssh_key" {
  type = string
  description = "SSH public key for the user in cloud-init"
}

variable "sudo_privileges" {
  description = "Sudo privileges configuration in cloud-init"
  type        = string
}

variable "ssh_pwauth" {
  description = "Default user ssh login allowed with password."
  type        = string
}

variable "password" {
  description = "Default user's password in cloud-init"
  type        = string
}