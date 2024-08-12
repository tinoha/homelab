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
  type        = string
  default     = "1"
}

variable "vm_vcpu" {
  description = "The number of vCPUs for the vm."
  type        = string
  default     = "2"
}

variable "vm_memory" {
  description = "The amount of memory (in MB) for the vm."
  type        = string
  default     = "4096"
}

variable "vm_cpu_mode" {
  description = "The CPU mode for the vm."
  type        = string
  default     = "host-passthrough"
}

variable "vm_qemu_agent" {
  description = "Use QEMU agent: true|false "
  type        = string
  default     = "false"
}

variable "network_wait_for_lease" {
  description = "Wait address is assigned to the interface: true|false "
  type        = string
  default     = "false"
}

variable "vm_disk_scsi" {
  description = "Whether the disk should use SCSI."
  type        = string
  default     = "true"
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

variable "cloud_init_data_file" {
  description = "Path to the user-data file. If not set default is ./cloud-init/user-data"
  type        = string
  default     = null # Default to null, meaning no override
}



