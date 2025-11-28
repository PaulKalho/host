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

module "vaultwarden_vm" {
	source = "../modules/proxmox-vm"

	name        = "vaultwarden-nixos-vm"
	target_node = "Proxmox-VE"

	clone = "ubuntu-cloudinit"

	cores = 1
	sockets = 1
	memory   = 512
	
	network_bridge = "vmbr1"
	vlan_tag       = 10
	
	ip             = "69.69.11.24"
	netmask        = 24
	gateway        = "69.69.11.1"

	cloudinit_storage = "local"
	disk_size		 = 8
	disk_storage     = "tbstorage"

	ciuser     = data.sops_file.secrets.data["vaultwarden.user"]
	cipassword = data.sops_file.secrets.data["vaultwarden.password"]

	sshkey_file = file("${path.module}/../../keys/paulkalhorn.pub")

	tags = "paul,nixos"
}
