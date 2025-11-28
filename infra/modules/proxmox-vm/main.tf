terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
    }
  }
}

resource "proxmox_vm_qemu" "vm" {
	name        = var.name
	target_node = var.target_node
	
	clone = var.clone
	full_clone = var.clone != null ? true : false

	cpu {
		cores   = var.cores
		sockets = var.sockets
	}

	memory = var.memory
	scsihw = "virtio-scsi-pci"

	network {
		id     = 0
		bridge = var.network_bridge
		model  = "virtio"
		tag    = var.vlan_tag
	}

	disks {
		ide {
			ide2 {
				cloudinit {
					storage = var.cloudinit_storage
				}
			}
		}
		scsi {
			scsi0 {
				disk {
					size    = var.disk_size
					storage = var.disk_storage
				}
			}
		}
	}

	serial {
		id   = 0
		type = "socket"
	}

	os_type   = "cloud-init"
	ipconfig0 = "ip=${var.ip}/${var.netmask},gw=${var.gateway}"

	ciuser      = var.ciuser
	cipassword  = var.cipassword
	sshkeys     = var.sshkey_file

	bios = "ovmf"
	boot = "order=scsi0;ide2;net0"
}
