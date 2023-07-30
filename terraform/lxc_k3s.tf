# We will start with one master k3s container

resource "proxmox_lxc" "k3s_master" {
  hostname        = "k3s-master01"
  cores           = 1
  memory          = "1024"
  swap            = "2048"
  ssh_public_keys = var.ssh_key
  password        = var.password
  features {
    nesting = true
  }
  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "10.1.1.221/24"
    gw     = "10.1.1.1"
  }
  ostemplate   = var.ostemplate
  target_node  = var.target_node
  unprivileged = false
  onboot       = true
  start        = true
  vmid         = var.master_vmid

  connection {
    type     = "ssh"
    user     = "root"
    password = var.proxmox_password
    host     = var.proxmox_host
  }

  # Now we will add some modifications to the containers based on
  # https://betterprogramming.pub/rancher-k3s-kubernetes-on-proxmox-containers-2228100e2d13
  # > Additional Configuration

  provisioner "remote-exec" {
    inline = [
      "echo lxc.apparmor.profile: unconfined >> /etc/pve/lxc/${var.master_vmid}.conf",
      "echo lxc.cgroup.devices.allow: a >> /etc/pve/lxc/${var.master_vmid}.conf",
      "echo lxc.cap.drop: >> /etc/pve/lxc/${var.master_vmid}.conf",
      "echo lxc.mount.auto: 'proc:rw sys:rw' >> /etc/pve/lxc/${var.master_vmid}.conf"
    ]
  }

  # Next step is to add a custom kernel

  provisioner "remote-exec" {
    inline = [
      "pct push ${var.master_vmid} /boot/config-$(uname -r) /boot/config-$(uname -r)"
    ]
  }
}

# Now we will create n workers. We can create multible workers with the
# count number.

resource "proxmox_lxc" "k3s_worker" {
  count           = 3
  hostname        = "k3s-worker0${count.index + 1}"
  ssh_public_keys = var.ssh_key
  password        = var.password
  cores           = 1
  memory          = "1024"
  swap            = "2048"
  features {
    nesting = true
  }
  rootfs {
    storage = "local-lvm"
    size    = "8G"
  }
  network {
    name   = "eth0"
    bridge = "vmbr0"
    ip     = "10.1.1.23${count.index + 1}/24"
    gw     = "10.1.1.1"
  }
  ostemplate   = var.ostemplate
  target_node  = var.target_node
  unprivileged = false
  onboot       = true
  start        = true
  vmid         = var.worker_vmid + count.index

  connection {
    type     = "ssh"
    user     = "root"
    password = var.proxmox_password
    host     = var.proxmox_host
  }

  # Now we will add some modifications to the containers based on
  # https://betterprogramming.pub/rancher-k3s-kubernetes-on-proxmox-containers-2228100e2d13
  # > Additional Configuration

  provisioner "remote-exec" {
    inline = [
      "echo lxc.apparmor.profile: unconfined >> /etc/pve/lxc/${var.master_vmid}.conf",
      "echo lxc.cgroup.devices.allow: a >> /etc/pve/lxc/${var.master_vmid}.conf",
      "echo lxc.cap.drop: >> /etc/pve/lxc/${var.master_vmid}.conf",
      "echo lxc.mount.auto: 'proc:rw sys:rw' >> /etc/pve/lxc/${var.master_vmid}.conf"
    ]
  }
}

