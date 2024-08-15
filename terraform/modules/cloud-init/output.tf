output "user_data_mime" {
   value = data.cloudinit_config.user_data.rendered
   description = "Rendered multi-part MIME output from cloud-init."
}

output "user_data_txt" {
  value = local.user_data
  description = "Rendered user-data output from cloud-init"
}