data "cloudinit_config" "user_data" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "user-data.tftpl"
    content_type = "text/cloud-config"
    content = local.user_data
  }
}

locals {

  # Set default user-data file path
  data_file_default = "${path.module}/templates/user-data.tftpl"

  # Is data_file variable set and is the file found
  is_var_data_file = var.data_file != "" ? true : false
  is_data_file_found = var.data_file != "" ? fileexists(var.data_file) : false

  # Set path to user-data file
  user_data = local.is_var_data_file == true && local.is_data_file_found == true ? file(var.data_file) : templatefile(local.data_file_default,local.vars)
  
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