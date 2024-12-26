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

resource "proxmox_vm_qemu" "nextcloud_vm" {
    name = "nextcloud-vm"
    target_node = "Proxmox-VE"

    clone = "ubuntu-cloudinit"

    cores = 4
    sockets = 1
    cpu = "host"
    memory = 4096
    scsihw = "virtio-scsi-pci"

    network {
        bridge = "vmbr1"
        model = "virtio"
        tag = "10"
    } 

    disks {
        ide {
            ide2 {
                cloudinit {
                    storage = "local"
                }
            }
        }
        scsi {
            scsi0 {
                disk {
                    size = 20
                    storage = "local"
                }
            }
        }
    }

    serial {
        id = 0
    }

    os_type = "cloud-init"
    ipconfig0 = "ip=69.69.11.23/24,gw=69.69.11.1"

    ciuser = data.sops_file.secrets.data["nextcloud_vm.user"]
    cipassword = data.sops_file.secrets.data["nextcloud_vm.password"]

    sshkeys = file("${path.module}/../../keys/paulkalhorn.pub")    

    bios = "ovmf"
    boot = "order=scsi0;ide2;net0"
}
