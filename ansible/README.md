# Deploy infrastructure with Ansible

## Deploy Vanilla Kubernetes Cluster on Ubuntu Linux VMs

Here are instructions to deploy a working Kubernetes cluster. Please note following regarding the usage of the `deploy_kubernetes_cluster.yaml` playbook:

- The inventory allows only one control-plane node.
- One or more worker-nodes cam be added to the inventory.
- The entire cluster must be deployed in a single run. Joining additional worker-nodes afterwards, upgrading or destroying the cluster is not implemented.
- To rerun the deployment, you must clean up the entire cluster beforehand.
- Joining additional worker nodes afterwards, upgrading or destroying the cluster is not implemented.
- The playbook is idempotent, meaning it can be run multiple times without unnecessary changes (the Ubuntu OS will be updated if 3600 seconds have passed since previous update).
- The playbook is built and tested on Ubuntu 24.04 LTS, which is same version used in all Terraform configs.

### Preparations

1. Ensure the SSH key used during VM deployment for the sysadmin account is avaible. Ansible requires this key to access managed hosts. By default, the SSH key location is:
   ```bash
   # ~/.ssh/id_ed25519_sysadmin
   ```
2. Update the relevant Ansible inventory file with actual IP addresses and ssh ports of the VMs, based on the environment. Refer to provided inventory templates:

- Azure deployments: `ansible/inventory/prod/azure`
  - Assing one VM to the `controlplane` group, and other VMs to the `worker` group.
  - Set the `ansible_host` for each VM to the public IP address of the load balancer
  - Set `ansible_port` to the VM specific NAT port for for SSH access
- KVM deployments: `ansible/inventory/prod/kvm`
  - Put one VM in the `controlplane` group, and other VMs to the `worker` group.
  - Replace the placeholder IP addressess in the template with actual VM IP addresses

3. Review the parameter definitions in `inventory/prod/group_vars/all`. While the default values are generally sufficient, you may want to customize specific parameters. For example, you can modify the `k8s_user_ssh_key_file` to use your own SSH key for connecting as the kubeadmin user.

4. Move to the Ansible main directory

   ```bash
   cd ./ansible
   ```

5. Ensure Ansible inventory is valid, that there is one control-plane and one or many worker-nodes with correct IP addresses. There should be no need to change any variables from defaults. Following command can be used to check inventory

   ```bash
   ansible -i ./inventory/prod/<inventory> all --list-hosts
   ansible-inventory -i inventory/prod/<inventory> --list
   ```

6. Backup of your local known_hosts file so you can restore it later if needed.

   ```bash
   cp -p  ~/.ssh/known_hosts ~/.ssh/known_hosts.backup
   ```

7. Initialize ssh connectivity to each VM by accepting the host key and adding it to the `~/.ssh/known_hosts`. Choose one of the methods: a,b or c.

   **a)** Run a playbook that uses `ssh-keygen` to collect and add host keys to the known_hosts file.

   ```bash
   ansible-playbook -i ./inventory/prod/<inventory> ./playbooks/initialize_ssh_known_hosts.yaml
   ```

   **b)** Login with ssh and accept the host key.

   ```bash
   ssh sysadmin@<vm_ip_address> [-p <ssh_port>] -i ~/.ssh/id_ed25519_sysadmin
   ```

   **c)** Run ssh-keyscan and forward output to the known_hosts file.

   ```bash
   ssh-keyscan -T 5 [-p <ssh_port>] <vm_ip_address> >> ~/.ssh/known_hosts
   ```

8. Verify Ansible's ability to connect to each VM using a ping test
   ```bash
   ansible -i ./inventory/prod/kvm all  -m ping
   ```

### Deploy Kubernetes Cluster

Here are the instructions how to prepare the nodes for Kubernetes and deploy the cluster. In case the deployment fails, try fix the issue, cleanup and run the playbook again.

1. Run the playbook to prepare the nodes for Kubernetes and deploy the cluster. In case the deployment fails, investigate the issue, clean up as instructed in chapter _Clean Up_ and try to run playbook again.

   ```bash
   ansible-playbook -i ./inventory/prod/<inventory> ./playbooks/deploy_kubernetes_cluster.yaml
   ```

2. Login to kubernetes control-plane as kubeadmin user and check the cluster state. If you modified `k8s_user_ssh_key_file` in ansible `./inventory/prod/group_vars/all` file, update the key option (`-i`) accordingly

   ```bash
   ssh kubeadmin@<vm_ip_address> [-p <ssh_port>] -i ~/.ssh/id_ed25519_sysadmin.pub

   kubectl get nodes -o wide

   # In case the cluster deployment was sucessfull, output should look similar like below:
   kubeadmin@kube-1:~$ kubectl get nodes -o wide
   NAME     STATUS   ROLES           AGE     VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE             KERNEL-VERSION     CONTAINER-RUNTIME
   kube-1   Ready    control-plane   3m35s   v1.31.1   192.168.1.224   <none>        Ubuntu 24.04.1 LTS   6.8.0-45-generic   containerd://1.7.22
   kube-2   Ready    <none>          2m33s   v1.31.1   192.168.1.222   <none>        Ubuntu 24.04.1 LTS   6.8.0-45-generic   containerd://1.7.22

   ```

### Clean Up

Find below instruction how to clean up (destroy) the Kubernetes cluster created by the Ansible playbook. This would be needed if you want to rerun the deployment for some reason.

1. Run kubeadm reset on each node (control-plane and worker nodes) and remove the `/home/kubeadmin/.kube/config` file from control-plane. For example, run below command, replacing <vm_ip_address> (and port if Azure env)

   ```bash
   ssh sysadmin@<vm_ip_address> [-p <ssh_port>] -i ~/.ssh/id_ed25519_sysadmin "sudo kubeadm reset --force ; sudo rm --force /home/kubeadmin/.kube/config"
   ```

2. Now the cluster should be cleaned up.
