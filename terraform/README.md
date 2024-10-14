# Infrastructure Deployment with Terraform

## Azure Deployments

Find below detailed instructions to deploy shared network infrastructure and two Ubuntu linux VMs where you can later deploy Kubernetes using Ansible. You may also try to deploy other terraform environment configs e.g. myapp.

Terraform configurations use [azurerm provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs) to manage Azure resources.

### Prerequisites

Before proceeding, ensure you have the following tools installed and configured:

- Azure subscription
- Azure CLI

### Preparations

1. Log in to Azure with Azure client (az) and choose the subscription id where to deploy resources.

   ```bash
   az login
   az account list -o table
   ```

2. Set environment variable for Terraform to use the correct subscription

   ```bash
   export TF_VAR_az_subscription_id="<your_azure_subscription_id>"
   ```

3. Ensure that SSH key pair is generated for the sysadmin user, which is the default account created by Terraform on all deployed VMs. This key is needed to login into the VM's, and is also needed by Ansible to connect to the VMs

```bash
ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_sysadmin -C "sysadmin@control"
```

### Deploy Shared Network Resources

`terraform/environments/azure/shared/`

Deploy shared network resources first. Every other Azure terraform environment depends on these the resources, and also read it's local terraform state file.

1.  Move to environment specific directory, initialize Terraform to download providers etc.

    ```bash
    cd terraform/environments/azure/shared
    terraform init
    ```

2.  To allow ssh access from the internet to the subnets then enable following parameter in terraform.tfvars file. Create file if it does not exist.

    ```bash
    # terraform.tfvars file
    allow_ssh_internet_inbound = true
    ```

3.  Check what will be done, no changes being done yet
    ```bash
    cd /terraform/shared
    terraform plan
    ```
4.  Apply the planned config
    ```bash
    terraform apply
    ```
5.  Some Terraform commands to get info from the deployed resources and state
    ```bash
    terraform output
    terraform show
    ```
6.  Check with Azure CLI what was actually deployed. Output should be similar as below.

    ```
    az resource list --resource-group prod-shared-network-rg --output table
    ```

    ```
    Name                  ResourceGroup           Location    Type                                     Status
    --------------------  ----------------------  ----------  ---------------------------------------  --------
    prod-shared-lb-pip    prod-shared-network-rg  eastus      Microsoft.Network/publicIPAddresses
    prod-app-subnet-nsg   prod-shared-network-rg  eastus      Microsoft.Network/networkSecurityGroups
    prod-shared-vnet      prod-shared-network-rg  eastus      Microsoft.Network/virtualNetworks
    prod-k8s-subnet-nsg   prod-shared-network-rg  eastus      Microsoft.Network/networkSecurityGroups
    prod-mgmt-subnet-nsg  prod-shared-network-rg  eastus      Microsoft.Network/networkSecurityGroups
    prod-shared-lb        prod-shared-network-rg  eastus      Microsoft.Network/loadBalancers
    ```

### Deploy Ubuntu Linux VMs

`terraform/environments/azure/prod/`

Deploy two linux VMs on the shared network subnet (`prod-k8s-subnet`) for kubernetes cluster. When ready you may proceed to deploy the cluster using Ansible, or optionally try deploying other azure Terraform environments.

1. Move to environment specific directory, initialize Terraform to download providers etc.

   ```bash
   cd terraform/environments/azure/prod
   terraform init
   ```

2. To allow ssh access from the internet enable below parameter in `terraform.tfvars`. Create file if it does not exist. Note that ssh access need to be enabled also on subnet level in order to allow connection.

   ```bash
   # terraform.tfvars file
   allow_ssh_internet_inbound = true
   ```

3. Check what will be done if applied, no changes are being done yet
   ```bash
   terraform plan
   ```
4. Apply the planned config
   ```bash
   terraform apply
   ```
5. Some Terraform commands to get info from the deployed resources and state
   ```bash
   terraform output
   terraform show
   ```
6. Check with Azure CLI what was actually deployed. Output should be similar as below.

   ```bash
   az resource list --resource-group k8s-cluster-rg --output table
   ```

   ```
   Name                                                           ResourceGroup    Location    Type                                     Status
   -------------------------------------------------------------  ---------------  ----------  ---------------------------------------  --------
   prod-k8s-control-01-nic                                        k8s-cluster-rg   eastus      Microsoft.Network/networkInterfaces
   prod-k8s-node-01-nsg                                           k8s-cluster-rg   eastus      Microsoft.Network/networkSecurityGroups
   prod-k8s-control-01-nsg                                        k8s-cluster-rg   eastus      Microsoft.Network/networkSecurityGroups
   prod-k8s-node-01-nic                                           k8s-cluster-rg   eastus      Microsoft.Network/networkInterfaces
   prod-k8s-control-01                                            k8s-cluster-rg   eastus      Microsoft.Compute/virtualMachines
   prod-k8s-control-01_OsDisk_1_a84e5cff10df430d840b171a58fe96ad  k8s-cluster-rg   eastus      Microsoft.Compute/disks
   prod-k8s-node-01                                               k8s-cluster-rg   eastus      Microsoft.Compute/virtualMachines
   prod-k8s-node-01_OsDisk_1_fa2e36bfd04c470595c2502f628670fd     k8s-cluster-rg   eastus      Microsoft.Compute/disks
   shutdown-computevm-prod-k8s-control-01                         k8s-cluster-rg   eastus      Microsoft.DevTestLab/schedules
   shutdown-computevm-prod-k8s-node-01                            k8s-cluster-rg   eastus      Microsoft.DevTestLab/schedules
   ```

7. Record the public load balancer IP address and reserved inbound NAT ports for each VM.

   ```bash
   # Loadbalancer public IP
   az network  public-ip show  -g prod-shared-network-rg --name prod-shared-lb-pip --query {publicIP:ipAddress}

   # NAT ports of VMs for internet SSH access
   az network lb show -g prod-shared-network-rg -n prod-shared-lb \
    --query backendAddressPools[].loadBalancerBackendAddresses[].[name,inboundNatRulesPortMapping] \
    -o table
   ```

8. Test ssh access to the vms

   ```bash
   ssh sysadmin@<publicIP> -p <frontendPort> -i ~/.ssh/id_ed25519_sysadmin
   ```

## KVM/QEMU (libvirt) Deployments

Deploy two or more linux VMs on the local network (linux bridge).

Terraform configurations use [libvirt provider](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs) (dmacvicar/libvirt) to manage libvirt/KVM resources.

### Prerequisites

The following are essential requirements for the host system to create and manage VMs using Terraform on a Libvirt/KVM environment. This list covers the minimum capabilities needed but may vary depending on your Linux distribution.

1. Ensure that KVM/QEMU virtualization is installed on the host.

2. Ensure the `libvirt` toolkit and the `libvirtd` daemon are installed.

3. Verify that the necessary `libvirt` services are running and enabled. Below is an example for SUSE Leap 15.6:
   ```bash
   sudo systemctl status libvirtd.service
   sudo systemctl status libvirtd.socket
   sudo systemctl enable libvirtd.service libvirtd.socket --now
   ```
4. Ensure a Linux network bridge is correctly set up and mapped to an appropriate network. The default bridge used in the Terraform configuration is br0 (this can be changed by adjusting the `network_bridge` variable). To check for available bridges:
   ```bash
   ip link show type bridge
   ```
5. Ensure your local network has an active DHCP service to assign IP addresses to the VMs.

6. Add your user to the relevant groups (e.g., libvirt, kvm) to enable rootless operations of libvirt commands. Without this, Terraform will continually prompt for a sudo password when executing commands.

### Deploy Ubuntu Linux VMs

`terraform/environments/kvm/prod/`

1. Download Ubuntu cloud image.

   ```bash
   curl -LO --output-dir /tmp https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img
   ```

2. Define the image source in Terraform variables. Create the file if it does not exist, and add row as below.

   ```bash
   # File terraform.tfvars
   image_source = /tmp/noble-server-cloudimg-amd64.img
   ```

3. Move to the environment specific directory, initialize Terraform to download providers etc.

   ```bash
   cd terraform/environments/kvm/prod
   terraform init
   ```

4. Check what changes will be done if applied, no changes are done at this step
   ```bash
   terraform plan
   ```
5. Apply the planned config
   ```bash
   terraform apply
   ```
6. Some Terraform commands to get info from the deployed resources and state
   ```bash
   terraform output
   terraform show
   ```
7. Record the dynamic IP addresses of the VMs using the terraform output command. If you want to keep the IPs consistent over time, one option is to set up address reservations on your DHCP server.

   ```bash
   terraform output
   ```

   ```bash
   # Example output snippet
   vm_info = [
   {
      "id" = "852a8365-eed3-40bf-8451-5bf0aa19224a"
      "name" = "kube-1"
      "private_ip" = "192.168.1.80"
   },
   {
      "id" = "eac88ad9-826c-4988-952d-902f79d6f615"
      "name" = "kube-2"
      "private_ip" = "192.168.1.81"
   },
   ]
   ```

   Note: Since the IPs are dynamically assigned, they may change after a reboot. To keep these VMs for an extended period, consider configuring static IP reservations on your local DHCP server.

8. Test ssh access to the vms

   ```bash
   ssh sysadmin@<private_ip>  -i ~/.ssh/id_ed25519_sysadmin
   ```

## Clean up Terraform Deployed Resources

To remove all resources created by Terraform, navigate to the appropriate environment directory and run the following command:

1. Change directory to the specific environment:

   ```bash
   cd terraform/environments/<kvm|azure>/<env>
   ```

2. Run the destroy command to clean up the resources:
   ```bash
   terraform destroy
   ```
