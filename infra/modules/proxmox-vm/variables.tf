variable "name" {}
variable "target_node" {}
variable "clone" {
	type = string
	default = null
	nullable = true
}

variable "cores" { type = number }
variable "sockets" { type = number }
variable "memory" { type = number }

variable "network_bridge" {}
variable "vlan_tag" { type = number }

variable "cloudinit_storage" {}
variable "disk_storage" {}
variable "disk_size" { type = number }

variable "ip" {}
variable "netmask" {}
variable "gateway" {}

variable "ciuser" {}
variable "cipassword" {}
variable "sshkey_file" {}
