terraform {
  required_providers {
    sops = {
      source = "carlpett/sops"
    }
  }
}

data "sops_file" "secrets" {
	source_file = "${path.module}/secrets.yaml"
}

module "nextcloud_vm" {
	source = "../modules/proxmox-vm"

	name        = "nextcloud-nixos-vm"
	target_node = "Proxmox-VE"

	cores = 4
	sockets = 1
	memory   = 10240
	
	network_bridge = "vmbr1"
	vlan_tag       = 10
	
	ip             = "69.69.11.23"
	netmask        = 24
	gateway        = "69.69.11.1"

	cloudinit_storage = "local"
	disk_size		 = 500
	disk_storage     = "tbstorage"

	ciuser     = data.sops_file.secrets.data["nextcloud_vm.user"]
	cipassword = data.sops_file.secrets.data["nextcloud_vm.password"]

	sshkey_file = file("${path.module}/../../keys/paulkalhorn.pub")
}
