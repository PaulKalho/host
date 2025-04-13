{ config, pkgs, modulesPath, lib, ... }:
let
    dbDumpPath = "/tmp/nextcloud-db.sql";
    pg_dump = "${pkgs.postgresql}/bin/pg_dump";
    runAs = user: cmd: "${pkgs.sudo}/bin/sudo -u ${user} -- ${cmd}";
in {
    nixpkgs.hostPlatform = "x86_64-linux";
    
    environment.systemPackages = with pkgs; [ 
        borgbackup 
    ];

    sops.secrets = {
        "nextcloud/adminPass" = {
            owner = "nextcloud";
        };
        "backups/remotePrivateKey" = {
            path = "/etc/ssh/borg_backup_key";
            mode = "0600";
        };
        "backups/borgPassphrase" = {};
        "backups/remoteRepo" = {};
    };
    
    services.borgbackup.jobs.nextcloud = {
        # We need to allow borg to read/write to nextcloud directory for enabling maintenance mode
        readWritePaths = [
            "/var/lib/nextcloud/" 
        ];
        paths = [ 
            "/var/lib/nextcloud/config" 
            "/var/lib/nextcloud/data" 
            "${dbDumpPath}"
        ];
        environment = {
            BORG_PASSPHRASE_FD = config.sops.secrets."backups/borgPassphrase".path;
            BORG_RSH = "ssh -p23 -i ${config.sops.secrets."backups/remotePrivateKey".path} -o StrictHostKeyChecking=no";
        };
        # Placeholder will be replaced from the sops file in the preHook
        repo = "ssh://placeholder@localhost/dummy-repo";
        encryption = {
            mode = "repokey";
            passCommand = "cat ${config.sops.secrets."backups/borgPassphrase".path}";
        };
        compression = "lz4";
        exclude = [ "/var/lib/nextcloud/tmp/*" ];
        preHook = ''
            # Set the BORG_REPO from the sops file
            export BORG_REPO=$(cat ${config.sops.secrets."backups/remoteRepo".path})

            echo "Enabling maintenance mode..."
            ${lib.getExe config.services.nextcloud.occ} maintenance:mode --on || exit 1

            echo "Dumping PostgreSQL database..."
            ${runAs "postgres" "${pg_dump} nextcloud > ${dbDumpPath}"} || exit 1
        '';
        postHook = ''
            echo "Disabling maintenance mode..."
            ${lib.getExe config.services.nextcloud.occ} maintenance:mode --off || exit 1
            
            rm -rf ${dbDumpPath}
        '';
        # TODO: Add settings for schedule & how many backups will be saved 
    };

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

    # TODO: Set State Version!
}
