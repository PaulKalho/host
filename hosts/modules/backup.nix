{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.backup;
in
{
  options.services.backup = {
    enable = lib.mkEnableOption "borg backups";

    readWritePaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    paths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    exclude = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    extraPreHook = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };

    extraPostHook = lib.mkOption {
      type = lib.types.lines;
      default = "";
    };

    user = lib.mkOption {
      type = lib.types.str;
      default = "root";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      borgbackup
    ];

    sops.secrets = {
      "backups/remotePrivateKey" = {
        path = "/etc/ssh/borg_backup_key";
        mode = "0600";
      };
      "backups/borgPassphrase" = { };
      "backups/remoteRepo" = { };
    };

    services.borgbackup.jobs.main = {
      readWritePaths = cfg.readWritePaths;

      paths = cfg.paths;

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
      exclude = cfg.exclude;

      preHook = ''
        export BORG_REPO=$(cat ${config.sops.secrets."backups/remoteRepo".path})
        ${cfg.extraPreHook}
      '';

      postHook = ''
        ${cfg.extraPostHook}
      '';

      startAt = "daily";
      prune.keep = {
        daily = 7;
        weekly = 4;
        monthly = 3;
      };
    };
  };
}
