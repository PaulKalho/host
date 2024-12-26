{ config, pkgs, modulesPath, lib, ... }:{
    imports = [ ./disk-configuration.nix ./hardware-configuration.nix ../common/users.nix ];
    nixpkgs.hostPlatform = "x86_64-linux";
    
    sops.secrets."nextcloud/adminPass".owner = "nextcloud";

    services.nextcloud = {
      enable = true;
      hostName = "cloud.kalhorn.org";
      configureRedis = true;
      database.createLocally = true;
      package = pkgs.nextcloud28;
      config = {
        dbtype = "pgsql";
        adminuser = "admin";
        adminpassFile = config.sops.secrets."nextcloud/adminPass".path; 
      };
      settings = {
        trusted_domains = [
            "cloud.kalhorn.org"
            "69.69.11.23"
        ];
      };
      maxUploadSize = "2G";
    };

    programs.zsh.enable = true;
    
    services.openssh = {
        enable = true;
        settings.PermitRootLogin = lib.mkForce "prohibit-password";
        settings.PubkeyAuthentication = "yes";
        settings.PasswordAuthentication = false;
    };

    # TODO: Define somewhere else
    sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}
