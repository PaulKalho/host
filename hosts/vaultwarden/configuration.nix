{
  config,
  pkgs,
  lib,
  ...
}:
{
  nixpkgs.hostPlatform = "x86_64-linux";

  environment.systemPackages = with pkgs; [
    borgbackup
  ];

  sops.secrets = {
    "vaultwarden/adminToken" = {
      owner = "vaultwarden";
    };
    "backups/remotePrivateKey" = {
      path = "/etc/ssh/borg_backup_key";
      mode = "0600";
    };
    "backups/borgPassphrase" = { };
    "backups/remoteRepo" = { };
  };

  services.borgbackup.jobs.vaultwarden = {
    paths = [
      "/var/lib/vaultwarden"
    ];

    environment = {
      BORG_PASSPHRASE_FD = config.sops.secrets."backups/borgPassphrase".path;
      BORG_RSH = "ssh -p23 -i ${
        config.sops.secrets."backups/remotePrivateKey".path
      } -o StrictHostKeyChecking=no";
    };

    repo = "ssh://placeholder@localhost/dummy-repo";
    encryption = {
      mode = "repokey";
      passCommand = "cat ${config.sops.secrets."backups/borgPassphrase".path}";
    };
    compression = "lz4";

    preHook = ''
      export BORG_REPO=$(cat ${config.sops.secrets."backups/remoteRepo".path})

      echo "Stopping Vaultwarden..."
      systemctl stop vaultwarden
    '';

    postHook = ''
      echo "Starting Vaultwarden..."
      systemctl start vaultwarden
    '';

    startAt = "daily";
    prune.keep = {
      daily = 7;
      weekly = 4;
      monthly = 3;
    };
  };

  services.vaultwarden = {
    enable = true;
    package = pkgs.unstable.vaultwarden;

    config = {
      DOMAIN = "https://vault.kalhorn.org";
      SIGNUPS_ALLOWED = false;
      ROCKET_PORT = 8222;
      ADMIN_TOKEN_FILE = config.sops.secrets."vaultwarden/adminToken".path;
      ROCKET_ADDRESS = "0.0.0.0";
    };
  };
  programs.zsh.enable = true;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = lib.mkForce "prohibit-password";
    settings.PubkeyAuthentication = "yes";
    settings.PasswordAuthentication = false;
  };

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  system.stateVersion = "24.11";
}
