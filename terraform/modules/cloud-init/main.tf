#locals {
  # user_data_file = var.data_file # == null ? "${path.module}/templates/default_user_data.tpl" : var.data_file
#}

# data "cloudinit_config" "user_data" {
#   gzip          = false
#   base64_encode = false

#   part {
#     filename     = "user-data.tftpl"
#     content_type = "text/cloud-config"
#     content = templatefile("${path.module}/${var.data_file}",{
#       username = var.username  # mandatory variable
#       sudo_section = var.sudo_privileges != "" ? "sudo: ${var.sudo_privileges}" : ""
#       groups_section = var.groups != "" ? "groups: ${var.groups}" : ""
#       ssh_authorized_keys_section = var.ssh_key != "" ? "ssh-authorized-keys:" : ""
#       ssh_key_section = var.ssh_key != "" ? "- ${var.ssh_key}" : ""
#       password_section = var.password != "" ? "password: ${var.password}" : ""
#       ssh_pwauth_section = var.ssh_pwauth != "" ? "ssh_pwauth: ${var.ssh_pwauth}" : ""
#       hostname_section = var.hostname != "" ? "hostname: ${var.hostname}" : ""
#       fqdn_section = var.fqdn != "" ? "fqdn: ${var.fqdn}" : ""
#       gecos_section = var.gecos != "" ? "gecos: ${var.gecos}" : ""
#     })
#   }
# }

data "template_file" "user_data" {

  template = file("${path.module}/templates/user-data.tftpl") 
  #template = file("${path.module}/templates/user-data") 
  
  vars = {
    # cloud-config user settings
    name_section = var.username != "" ? "- name: ${var.username}" : "" 
    shell_section = var.shell != "" ? "shell: ${var.shell}" : ""
    gecos_section = var.gecos != "" ? "gecos: ${var.gecos}" : ""
    sudo_section = var.sudo_privileges != "" ? "sudo: \"${var.sudo_privileges}\"" : ""
    groups_section = var.groups != "" ? "groups: ${var.groups}" : ""
    ssh_authorized_keys_section = var.ssh_key != "" ? "ssh_authorized_keys: [\"${var.ssh_key}\"]" : ""
   
    # cloud-config top-level settings
    password_section = var.password != "" ? "password: ${var.password}" : ""
    ssh_pwauth_section = var.ssh_pwauth != "" ? "ssh_pwauth: ${var.ssh_pwauth}" : "" 
    hostname_section = var.hostname != "" ? "hostname: ${var.hostname}" : ""
    fqdn_section = var.fqdn != "" ? "fqdn: ${var.fqdn}" : ""
   }
}

resource "local_file" "user_data_file" {
  content  = data.template_file.user_data.rendered
  filename = "${path.module}/output/user-data.yml"
}