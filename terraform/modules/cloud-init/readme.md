# Cloud-Init Module

This module sets up cloud-init configuration for provisioning a new user and system setup.
Check also default template file which contains additional settings.

## Inputs

| Name              | Description                           | Type   | Default                       |
| ----------------- | ------------------------------------- | ------ | ----------------------------- |
| `data_file`       | Path to cloud-init user-data template | string | `./templates/user-data.tftpl` |
| `username`        | User name for cloud-init              | string | `sysadmin`                    |
| `gecos`           | User description                      | string | `System administrator`        |
| `groups`          | User groups                           | string | `sudo`                        |
| `shell`           | User shell                            | string | `/bin/bash`                   |
| `ssh_key`         | SSH public key                        | string | ``                            |
| `sudo_privileges` | Sudo privileges configuration         | string | `ALL=(ALL) NOPASSWD:ALL`      |
| `password`        | Default user's password               | string | ``                            |
| `ssh_pwauth`      | Allow SSH login with password         | string | ``                            |
| `hostname`        | Hostname for cloud-init               | string | ``                            |
| `fqdn`            | Fully qualified domain name           | string | ``                            |

## Outputs

| Name             | Description                     |
| ---------------- | ------------------------------- |
| `user_data_mime` | Rendered multi-part MIME output |
| `user_data_txt`  | Rendered user-data output       |

## Example

```hcl
module "cloud_init" {
  source      = "./path/to/this/module"
  username    = "admin"
  ssh_key     = "ssh-rsa ABC123..."
}
```
