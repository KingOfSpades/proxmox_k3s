variable "ssh_key" {
  default = "YOUR SSH KEY HERE"
}

variable "password" {
  default = "topsecret"
}

variable "proxmox_host" {
  default = "PROXMOX HOST"
}

variable "target_node" {
  default = "PROXOMOX NAME"
}

variable "proxmox_server" {
  default = "https://PROXMOX_URL:8006/api2/json"
}

variable "ostemplate" {
  default = "local:vztmpl/debian-12-standard_12.0-1_amd64.tar.zst"
}

variable "proxmox_password" {
  default = "PROXMOX ROOT PASSWORD"
}

variable "master_vmid" {
  default = "200"
}

variable "worker_vmid" {
  default = "210"
}


