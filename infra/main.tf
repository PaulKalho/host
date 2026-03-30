module "nextcloud" {
	source = "./nextcloud"
}

module "vaultwarden" {
	source = "./vaultwarden"
}

module "stirlingpdf" {
	source = "./stirlingpdf"
}

module "monitoring" {
	source = "./monitoring"
}
