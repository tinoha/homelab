# Variables for module libvirt_vm
variable "libvirt_uri" {
  description = "URI for connecting to the libvirt service."
  type        = string
  default     = "qemu:///system"
}

variable "volume_pool" {
  description = "Name of the volume pool for VM storage."
  type        = string
  default     = "default"
}

variable "cloudinit_pool" {
  description = "Name of the cloud-init pool."
  type        = string
  default     = "default"
}

variable "image_source" {
  description = "Path to the VM image source."
  type        = string
  default     = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
}

variable "vm_name" {
  description = "Name of the VM."
  type        = string
  default     = "tfvm"
}

variable "vm_count" {
  description = "Number of VMs to create."
  type        = number
  default     = 1
}

variable "vm_vcpu" {
  description = "Number of virtual CPUs for the VM."
  type        = number
  default     = 2
}

variable "vm_memory" {
  description = "Amount of memory (in MB) for the VM."
  type        = number
  default     = 4096
}

variable "vm_qemu_agent" {
  description = "Enable QEMU guest agent."
  type        = bool
  default     = true
}

variable "network_bridge" {
  description = "Network bridge to connect the VM. Defined bride must exists in the system. It is not created by the module."
  type        = string
  default     = "br0"
}

variable "network_wait_for_lease" {
  description = "Wait for network lease before continuing."
  type        = bool
  default     = true
}

# Variables for cloud-init module

variable "data_file" {
  description = "Path to a cloud-init user-data file with static values (no templating). When set all  When not set the default template and will be used."
  type        = string
  default     = ""
}

### user-data users: section variables ###
variable "username" {
  description = "User name in cloud-init"
  type        = string
  default     = "sysadmin"
}

variable "gecos" {
  description = "User description in cloud-init"
  type        = string
  default     = "System administrator"
}

variable "groups" {
  description = "Groups of the user in cloud-init"
  type        = string
  default     = "sudo"
}

variable "shell" {
  description = "Shell for the user in cloud-init"
  type        = string
  default     = "/bin/bash"
}

variable "ssh_key" {
  type        = string
  default     = ""
  description = "SSH public key for the user in cloud-init"
}

variable "sudo_privileges" {
  description = "Sudo privileges configuration in cloud-init"
  type        = string
  default     = "ALL=(ALL) NOPASSWD:ALL"
}

#### user-data top level variables ### 
variable "hostname" {
  description = "hostname in cloud-init"
  type        = string
  default     = ""
}

variable "fqdn" {
  description = "fqdn in cloud-init"
  type        = string
  default     = ""
}

variable "ssh_pwauth" {
  description = "Default user ssh login allowed with password."
  type        = string
  default     = ""
}

variable "password" {
  description = "Default user's password in cloud-init"
  type        = string
  default     = ""
}