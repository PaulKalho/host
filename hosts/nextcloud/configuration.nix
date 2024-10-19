# TODO: load variables from sops
# TODO: test deployment on provisionised test vm (infra/nextcloud.tf)
{ config, pkgs, modulesPath, ... }:{
    imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

    boot.initrd.availableKernelModules = 
        [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
    boot.initrd.kernelModules = [ ];
    boot.kernelModules = [ "kvm-intel" ];
    boot.kernelParams = [
        "console=ttyS0,115200n8"
    ];
    boot.extraModulePackages = [ ];
    boot.loader.systemd-boot.enable = true;
    boot.loader.systemd-boot.editor = false;
    boot.loader.efi.canTouchEfiVariables = true;

    fileSystems."/" = {
        device = "/dev/disk/by-uuid/d848fbc0-9e9a-4a52-beab-7287f3e0ff0e";
        fsType = "ext4";
    };

    fileSystems."/boot" = {
        device = "/dev/disk/by-uuid/4660-52DD";
        fsType = "vfat";
    };

    swapDevices =
        [{ device = "/dev/disk/by-uuid/daddd0a9-b6c2-43df-a93a-d4bca361d0f8"; }];
    
    nixpkgs.hostPlatform = "x86_64-linux";

    services.postgresql = {
        enable = true;
        ensureDatabases = [ "nextcloud" ];
    };
    
    services.nextcloud = {
        enable = true;
        hostName = "cloud.gepaya.de";
        https = true;
        package = pkgs.nextcloud28;
        config = {
            dbtype = "pgsql";
            dbhost = "/run/postgresql";
            adminuser = "admin";
            adminpassFile = "./adminpass" ;
        };
        settings = {
            overwriteprotocol = "https";
            allow_local_remote_servers = true;
        };
        configureRedis = true;
        maxUploadSize = "1G";
    };

    services.nginx = {
        enable = true;
    };
}

