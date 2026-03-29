{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../modules/base.nix
    ../modules/networking.nix
    ../modules/qemu.nix
    ../modules/backup.nix
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

  deployment = {
    ip = "69.69.11.24";
    gateway = "69.69.11.1";
    hostname = "vaultwarden";
    domain = "vault.kalhorn.org";
    extraTCPPorts = [ 8222 ];
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

  services.backup = {
    enable = true;

    paths = [
      "var/lib/vaultwarden"
    ];

    extraPreHook = ''
      echo "Stopping Vaultwarden..."
      systemctl stop vaultwarden
    '';

    extraPostHook = ''
      echo "Starting Vaultwarden..."
      systemctl start vaultwarden
    '';
  };

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}
