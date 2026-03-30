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

module "monitoring_vm" {
	source = "../modules/proxmox-vm"

	name        = "monitoring.kalhorn.org"
	target_node = "Proxmox-VE"

	clone = "ubuntu-cloudinit"

	cores = 2
	sockets = 1
	memory   = 4096

	network_bridge = "vmbr1"
	vlan_tag       = 10

	ip             = "69.69.11.26"
	netmask        = 24
	gateway        = "69.69.11.1"

	cloudinit_storage = "local"
	disk_size		 = 40
	disk_storage     = "tbstorage"

	ciuser     = data.sops_file.secrets.data["monitoring.user"]
	cipassword = data.sops_file.secrets.data["monitoring.password"]

	sshkey_file = file("${path.module}/../../keys/paulkalhorn.pub")

	tags = "paul,nixos"
}
