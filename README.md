# Homelab Project: Automating Infrastructure (IaC) and Kubernetes Deployment on Azure and KVM

### 1. Overview

This project represents my personal learning journey and hands-on experiments with modern IT infrastructure technologies. It explores key areas such as cloud computing, virtualization, infrastructure automation, and container orchestration.

The primary goal of this project is to automate the provisioning and configuration of IT infrastructure using IaC tools like Terraform and Ansible in both cloud and on-premise environments, followed by the deployment of a fully functional vanilla Kubernetes cluster.

Key components include:

- **Azure Cloud**: Automated resource provisioning in Azure using Infrastructure as Code (IaC) tools.
- **Linux**: Installing and configuring Linux servers with IaC tools.
- **KVM/QEMU (Libvirt)**: Automated provisioning of Linux virtual machines in a local environment.
- **Infrastructure as Code (IaC) tools**: Terraform and Ansible are used for provisioning and configuration.
- **Kubernetes**: Automated deployment of a vanilla Kubernetes cluster with Ansible

I am publicly sharing this project to document my progress and potentially help others on their own learning paths. By detailing my approach and providing a working demo, I aim to contribute to the community while also deepening my understanding of these essential technologies. Through this project, I also hope to showcase my knowledge and skills in modern infrastructure tools and techniques.

Below, you’ll find detailed instructions on how to set up and run this demo. Have fun!

### 2. Technical Architecture

This section provides an overview of the current architecture for both the Azure cloud environment and the local KVM environment. Tools can provision different environments, but for the sake of simplicity and this demo, all naming conventions relate to the _prod_ environment which is also the default in this demo config. Many of the configs can be customized by environment variables.

#### 2.1. Azure Environment

- **Shared Network Resources**:

  - **Resource group** (`prod-shared-network-rg`)
    - All shared network resources are deployed in this resource group
  - **Virtual Network** (`prod-shared-vnet`)
    - **VNet Address Space**: `10.80.0.0/16`
  - **Management Subnet** (`prod-mgmt-subnet`):
    - **Address Prefix**: `10.80.0.0/24`
    - For hosting management VMs
  - **Application subnet** (`prod-app-subnet`):
    - **Address Prefix**: `10.80.1.0/24`
    - For hosting management VMs
  - **Kubernetes Subnet** (`prod-k8s-subnet`):
    - **Address Prefix**: `10.80.2.0/24`
    - For hosting Kubernetes cluster nodes.
  - **Azure Loadbalancer** (`prod-shared-lb`)
    - **PublicIPAddress** (`prod-shared-lb-pip`)
    - Load balancer provides outbound internet connectivity and inbound internet SSH connectivity (NAT) for the VMs.
  - **Network Security Groups** (`prod-<subnet-name>-subnet-nsg`)
    - Default NSG created for every subnet, with a rule to allow ssh internet inbound connectivity on subnet level. SSH access is customizable and can be disabled if no direct SSH access is needed"

- **Compute Resources - Individual Linux VMs for Kubernetes**:

  - **Linux OS version**: All VMs have Ubuntu 24.04

  - **K8s Control Plane (x1)** (`prod-k8s-control-01`):

    - **Subnet**: Deployed in the `prod-k8s-subnet`
    - **Static IP**: `10.80.2.10`
    - Control-plane in the Kubernetes cluster.

  - **K8s Worker Node (x1)** (`prod-k8s_node-01`):
    - **Subnet**: Deployed in the `prod-k8s-subnet`
    - **Static IP**: `10.80.2.20`
    - Worker node in the Kubernetes cluster

- **Compute Resources - Linux VMs in ScaleSet**:
  - **Linux OS version**: All VMs have Ubuntu 24.04
  - **ScaleSet** (`prod-myapp-sset`):
    - **Subnet**: Deployed in the `prod-app-subnet`
    - Deploy multiple VMs in the scaleset to host application workloads (configurable by vm_count)."

#### 2.2. Local KVM Environment

- **Network Setup**:

  - **Linux Bridge**: All VMs are connected to a local Linux bridge which must be available prior provisioning VMs. Default bridge used in configs is `br0` and can be changed with a variable (vm_count). Current terraform config does not check or create the bridge.
  - **IP Addresses**: VMs are deployed using dynamic IP addressing (dhcp) so actual IP addressed depend on the user's local network setup.

- **Deployed Compute Resources**:
  - **K8s cluster VMs**:
    - **node-1**: Could be used as controlplane.
    - **node-2**: Could be used as worker nodes.
    - **node...**: Could be used as additional worker nodes

#### 2.3. Kubernetes Cluster (vanilla)

A working Kubernetes cluster consisting of single control-plane with one to many worker-nodes can be deployed by a single Ansible playbook. Joining additional worker nodes afterwards, upgrading or destroying the cluster is not implemented.

##### Used versions:

| Software   | Version   | Source URL                                                    |
| ---------- | --------- | ------------------------------------------------------------- |
| Kubernetes | 1.31.1    | [Kubernetes Official Site](https://kubernetes.io)             |
| Containerd | 1.7.22    | [Containerd GitHub](https://github.com/containerd/containerd) |
| Runc       | 1.1.14    | [Runc GitHub](https://github.com/opencontainers/runc)         |
| Flannel    | latest    | [Flannel GitHub](https://github.com/flannel-io/flannel)       |
| Ubuntu     | 24.04 LTS | [Ubuntu Official Site](https://ubuntu.com)                    |

##### Kubernetes Cluster Configuration

| Configuration Item       | Value                                            |
| ------------------------ | ------------------------------------------------ |
| Kubernetes Version       | 1.31.1                                           |
| Pod CIDR                 | 10.244.0.0/16                                    |
| Service CIDR             | 10.96.0.0/12                                     |
| Network Plugin           | Flannel                                          |
| Node Count               | 2                                                |
| Node Types               | 1x Controlplane, 1x Workers                      |
| Control Plane Resources  | 2 CPU, 2 GB RAM (min)                            |
| Worker Node Resources    | 2 CPU, 2 GB RAM (min)                            |
| API Server Configuration | default, no HA config (--control-plane-endpoint) |
| Etcd Configuration       | default                                          |
| Authentication Methods   | default, RBAC                                    |
| Gateway API              | n/a                                              |

#### 2.4. Simple ASCII Diagram

For a simple textual representation, here's an ASCII diagram of the networks and vms and created by default:

```
+----------------------------+
|        Azure VNet          |
|       10.80.0.0/16         |
|  +----------------------+  |
|  |    mgmt-subnet       |  |
|  |    10.80.0.0/24      |  |
|  |                      |  |
|  +----------------------+  |
|  +----------------------+  |
|  |    k8s-subnet        |  |
|  |    10.80.2.0/24      |  |
|  |  +----------------+  |  |
|  |  |   control-01   |  |  |
|  |  +----------------+  |  |
|  |  +----------------+  |  |
|  |  |     node-01    |  |  |
|  |  +----------------+  |  |
|  |                      |  |
|  +----------------------+  |
|  +----------------------+  |
|  |     app-subnet       |  |
|  |    10.80.1.0/24      |  |
|  |                      |  |
|  +----------------------+  |
+----------------------------+

Local KVM Environment:

+----------------------------+
|       Local Network         |
|  (Linux Bridge Interface)   |
|  +---------------+          |
|  |  kube-1       |          |
|  +---------------+          |
|  +---------------+          |
|  |  kube-2       |          |
|  +---------------+          |
+-----------------------------+
```

### 3. Project Structure

The project is organized into several key directories. Below is an overview of the current structure and components:

#### `terraform/`

This directory contains Terraform configurations for provisioning infrastructure both in the Azure cloud and locally using KVM/QEMU (libvirt). The structure is as follows:

- **`terraform/environments/azure/shared/`**

  - Contains configurations for shared network resources used across different Azure environments which other Azure environments depends on.
  - Includes foundational shared components such as load balancer, virtual network (VNet), subnets and network security groups (NSG).

- **`terraform/environments/azure/prod/`**

  - Configurations for deploying individual Ubuntu Linux VMs on Azure.
  - Depends on the Azure shared network resources.
  - Used to set up two VMs for the Kubernetes cluster use.

- **`terraform/environments/azure/myapp/`**

  - Configuration for deploying linux vm's in Azure scaleset
  - Depends on the Azure shared network resources.

- **`terraform/environments/kvm/`**

  - Contains configurations for deploying Ubuntu Linux VMs locally using KVM/QEMU virtualization (Libvirt).
  - Used for deploying VMs for a local Kubernetes cluster

- **Terraform Workspaces and Environment Variables:**
  Terraform Azure configurations support environment variables and workspaces, allowing to provision different environments such as `prod`, `default`, and `dev` using the same base configuration.

#### `ansible/`

This directory holds all Ansible playbooks and related resources.

- **`ansible/inventory/prod/`**

  - `azure` and `kvm`: separate inventories for Azure and local env Kubernetes cluster deployments
  - `group_vars/all`: for customizing Kubernetes cluster deployment

- **`ansible/playbooks/`**
  - `deploy_kubernetes_cluster.yaml` - Deploys vanilla Kubernetes cluster
  - `initialize_ssh_known_hosts.yaml` - Ensures the Ansible control node trusts the VMs by adding their SSH keys to the known_hosts file, preventing prompts during future connections."

### 4. Installation and Usage

This section provides an overview of the steps required to set up and deploy the infrastructure using IaC tools. For detailed instructions specific to Terraform and Ansible, please refer to their respective README files.

Start with chapters prerequisites and general preparations.

#### 4.1. Prerequisites

Before proceeding, ensure you have the following tools installed and configured. The version numbers listed are the last used during the development and testing of this demo lab, but any recent version of these tools should work.

- Terraform (v1.9.4)
- Ansible (v2.6.15)
- Azure subscription
- Azure CLI
- KVM/QEMU (libvirt) for local virtualization

#### 4.2 General Preparations

1. Clone the repository
   ```bash
   git clone https://github.com/tinoha/homelab.git
   cd homelab
   ```
2. Generate SSH key pair for `sysadmin` user. This is the default account that will be created by Terraform on all deployed VMs, and is used also by Ansible to connect the VMs. Same user and key can be used for deployments in local (QEMU/KVM) and Azure environments.

   ```bash
   ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_sysadmin -C "sysadmin@control"
   ```

#### 4.3 Deploy the infrastructure and Kubernetes

The first steps is to provision the infrastructure (VMs, networks, etc.) either on local QEMU/KVM or on Azure cloud. For detailed instructions, refer to:

- [Terraform README](terraform/README.md) : Choose the appropriate Terraform deployment guide chapter based on your target environment (Azure or KVM).

Once the infrastructure is provisioned, deploy a Kubernetes cluster with Ansible. For instructions, see:

- [Ansible README](ansible/README.md) : This guide has instructions for both KVM and Azure deployments

### 6. Project Roadmap

### 7. References and Resources

Official documentation links:

Main tools used:

- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [Terraform Documentation](https://www.terraform.io/docs/)
- [Ansible Documentation](https://docs.ansible.com/)
- [Ubuntu Documentation](https://ubuntu.com/tutorials)
- [Azure Documentation](https://docs.microsoft.com/azure/)

### 8. License

This project is licensed under the MIT License. See the [LICENSE.txt](LICENSE.txt) file for details.

### 9. Contributions

This project is primarily a personal learning journey and a documentation of my progress with infrastructure automation and Kubernetes. While I welcome feedback, suggestions, and bug reports, please understand that the project is not designed for collaborative contributions at this time.

If you have insights, constructive criticism, or have encountered any issues, feel free to reach out. Your input is valuable and may help improve the project or clarify my documentation for others who may benefit from it too.

Thank you for your understanding, and I hope you find the content helpful!

### 10. Contact Information

For any inquiries, feedback, or suggestions, you can reach me by email at [your-email@example.com](mailto:your-email@example.com)
