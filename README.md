---
title: "Just another way to setup k3s on Proxmox"
author: "Christian ∆ Benstein"
---

This repo containers just another way to setup k3s on a Proxmox server using, Terraform and Ansible. I have choosen not to use cool modules or automation and rely soley on out of the box options to make this a bit future proof.

# Requirement

The following is not included and you need to set it up yourself

## Tooling

Make sure to have the following tools installed:

- Terraform
- Ansible
- Kubectl

## Proxmox

This repo sets up k3s on Proxmox but you need to install Proxmox youreselff. I'm using `debian-12-standard_12.0-1_amd64` because it came the most ready out of the box and it works with the k3s Traefik ingress. You will need to download the LCX image template on Proxmox yourself.

# Overview

This repo consists of 3 parts:

1. Installing the `infra` with Terraform
2. Creating a k3s `cluster` with Ansible
3. Creating a `test` deployment using `kubectl`

# Usage

You can use the included `Makefile` for quick setup. Follow along to create the cluster step by step. Please allow some time for each step to complete. Setting up the infra can take around 2 minutes, deploying k3s can take around 2-10 minutes (before the cluster is in a ready state).

## Creating the infra

This is taken care of by Terraform. Make sure to edit the following `var`'s in `terraform/vars.tf`:

- `ssh_key` the SSH key that will be used to connect to your containers
- `password` the password that will be used to connect to your containers
- `target_node` name of your Proxmox node
- `proxmox_server` the api url of your server
- `ostemplate` the LCX container template your are using
- `proxmox_password` root password for Proxmox. This is needed because we are setting up nodes with elivated permissions and that is currentlly only possible by connecting with the `root@pam` user
- `master_vmid` starting number for the `vmid` of the container
- `worker_vmid` starting number for the `vmid` of the container

### IP Config

You can find the IP config for the nodes in the `terraform/lcx_k3s.tf` file. Edit to your own content

### Deploy the infra

Now you can run `make infra` wich will run:

```bash
terraform -chdir=terraform init 
terraform -chdir=terraform apply
```

## Creating the cluster 

Make sure the `ansible/hosts` is up to date with the IP's that you have choosen for your infra

Cluster creation is done by Ansible using the `make cluster` command which will run:

```bash
ANSIBLE_CONFIG=ansible/ansible.cfg \
ansible-playbook ansible/playbook_configure_k3s.yaml \
--inventory ansible/hosts
```

The setup copy's the `kubeconfig` of the server and put's a modified copy in `ansible/kubeconfig_k3s.yaml`. At this point the cluster should be ready and you can verify this by running:

```bash
$ KUBECONFIG=ansible/kubeconfig_k3s.yaml kubectl get nodes
NAME           STATUS   ROLES                  AGE   VERSION
k3s-worker03   Ready    <none>                  5m   v1.27.3+k3s1
k3s-worker01   Ready    <none>                  5m   v1.27.3+k3s1
k3s-worker02   Ready    <none>                  5m   v1.27.3+k3s1
k3s-master01   Ready    control-plane,master    6m   v1.27.3+k3s1
```

## Deploying test

I have included a simple test deployment to test your new cluster. This can be deployed with `make test` wich will run:

```bash
KUBECONFIG=ansible/kubeconfig_k3s.yaml \
kubectl apply -f tests/test-deployment
```

After a short while this should serve a webpage on any of the worker IP's:

```bash
❯ curl  http://10.1.1.231
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
html { color-scheme: light dark; }
body { width: 35em; margin: 0 auto;
font-family: Tahoma, Verdana, Arial, sans-serif; }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```

