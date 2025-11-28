terraform {
	required_providers {
		proxmox = {
		  source  = "telmate/proxmox"
		  version = "3.0.2-rc01"
		}
		sops = {
		  source = "carlpett/sops"
		  version = "1.1.1"
		}
	}
}

data "sops_file" "global_secrets" {
	source_file = "${path.module}/secrets.yaml"
}

provider "proxmox" {
	pm_api_url          = data.sops_file.global_secrets.data["proxmox.endpoint"]
	pm_api_token_id     = data.sops_file.global_secrets.data["proxmox.api_token_id"]
	pm_api_token_secret = data.sops_file.global_secrets.data["proxmox.api_token_secret"]
	pm_tls_insecure     = true
}
