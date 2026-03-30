{
  config,
  pkgs,
  lib,
  ...
}:
let
  dbDumpPath = "/tmp/nextcloud-db.sql";
  mysqldump = "${pkgs.mariadb_114}/bin/mysqldump";
in
{
  imports = [
    ../modules/base.nix
    ../modules/networking.nix
    ../modules/qemu.nix
    ../modules/backup.nix

    ../modules/monitoring/agent.nix
    ../modules/monitoring/promtail.nix
  ];

  sops.secrets = {
    "nextcloud/adminPass" = {
      owner = "nextcloud";
    };
    "nextcloud/secretsJson" = {
      owner = "nextcloud";
    };
    "backups/remotePrivateKey" = {
      path = "/etc/ssh/borg_backup_key";
      mode = "0600";
    };
    "backups/borgPassphrase" = { };
    "backups/remoteRepo" = { };
  };

  deployment = {
    ip = "69.69.11.23";
    gateway = "69.69.11.1";
    hostname = "nextcloud";
    domain = "cloud.kalhorn.org";
    extraTCPPorts = [ 9100 ];
  };

  environment.etc."nextcloud-secrets.json".source = config.sops.secrets."nextcloud/secretsJson".path;
  services.nextcloud = {
    enable = true;
    hostName = "cloud.kalhorn.org";
    configureRedis = true;
    package = pkgs.nextcloud33;
    database.createLocally = true;
    config = {
      dbtype = "mysql";
      adminuser = "admin";
      adminpassFile = config.sops.secrets."nextcloud/adminPass".path;
    };
    settings = {
      overwriteprotocol = "https";
      trusted_domains = [
        "cloud.kalhorn.org"
        "cloud.gepaya.de"
        "69.69.11.23"
      ];
    };
    secretFile = "/etc/nextcloud-secrets.json";
    maxUploadSize = "2G";
  };

  services.backup = {
    enable = true;

    readWritePaths = [
      "/var/lib/nextcloud/"
    ];
    paths = [
      "/var/lib/nextcloud/config"
      "/var/lib/nextcloud/data"
      "${dbDumpPath}"
    ];
    exclude = [ "/var/lib/nextcloud/tmp/*" ];

    extraPreHook = ''
      # Set the BORG_REPO from the sops file
      export BORG_REPO=$(cat ${config.sops.secrets."backups/remoteRepo".path})

      echo "Enabling maintenance mode..."
      ${lib.getExe config.services.nextcloud.occ} maintenance:mode --on || exit 1

      echo "Dumping MariaDB database..."
      ${mysqldump} --socket=/run/mysqld/mysqld.sock --skip-ssl -u nextcloud nextcloud > ${dbDumpPath} || exit 1
    '';

    extraPostHook = ''
      echo "Disabling maintenance mode..."
      ${lib.getExe config.services.nextcloud.occ} maintenance:mode --off || exit 1

      rm -rf ${dbDumpPath}
    '';
  };

  services.monitoring.agent.enable = true;
  services.monitoring.promtail.enable = true;

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}
