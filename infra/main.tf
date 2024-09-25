terraform {
    required_providers {
        proxmox = {
            source = "telmate/proxmox"
            version = "3.0.1-rc4"
        }
        sops = {
            source = "carlpett/sops"
            version = "1.1.1"
        }
    }
}

data "sops_file" "secrets" {
    source_file = "${path.module}/secrets.yaml"    
}

provider "proxmox" {
    pm_api_url = data.sops_file.secrets.data["proxmox.endpoint"]
    pm_api_token_id = data.sops_file.secrets.data["proxmox.api_token_id"]
    pm_api_token_secret = data.sops_file.secrets.data["proxmox.api_token_secret"]
    pm_tls_insecure = true
}

resource "proxmox_lxc" "test_container" {
    target_node = "Proxmox-VE"
    hostname = "testTerraform"
    ostemplate = "tbstorage:vztmpl/debian-12-standard_12.2-1_amd64.tar.zst"
    password = #TODO
    unprivileged = true
    memory = "512"
    cores = 1

    rootfs {
        storage = "tbstorage"
        size = "8G"
    }

    network {
        name = "eth0"
        bridge = "vmbr1"
        ip = "69.69.11.12/24"
        tag = "10"
    }
}

