terraform {
  required_providers {
    proxmox = {
      source  = "telmate/proxmox"
      version = "2.9.14"
    }
  }
}

provider "proxmox" {

  # leave tls_insecure set to true unless you have your proxmox SSL certificate situation fully sorted out (if you do, you will know)

  pm_tls_insecure = true
  pm_api_url      = var.proxmox_server
  pm_user         = "root@pam"
  pm_password     = var.proxmox_password
}

