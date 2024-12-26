{ config, lib, pkgs, modulesPath, ... }: {
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules =
    [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" "sr_mod" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.kernelParams = [
    "console=ttyS0,115200n8"
  ]; # enable serial console for proxmox interaction
  boot.extraModulePackages = [ ];
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.editor = false; 
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    useDHCP = false;
    hostName = "nextcloudvm";
    # TODO: domain
    domain = "test.cloud.gepaya.de";

    interfaces.eth0 = {
      ipv4.addresses = [{
        address = "69.69.11.23";
        prefixLength = 24;
      }];
    };
    firewall.allowedTCPPorts = [ 80 443 ];

    defaultGateway = "69.69.11.1"; 
    nameservers = [ "8.8.8.8" "8.8.4.4" ];
  };
    
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
