{ config, pkgs, lib, ... }: 
let
    paulKey = builtins.readFile ../../keys/paulkalhorn.pub;
in {
    sops.secrets."user/paulPass"= {
        path = "/etc/secrets/paul_pass";
        owner = "root";
        mode = "0400";
        neededForUsers = true;
    };
    
    users = {
        mutableUsers = false;
        users.paul = {
            isNormalUser = true;
            shell = pkgs.zsh;
            extraGroups = [ "wheel" ];
            openssh.authorizedKeys.keys = [ paulKey ];
            hashedPasswordFile = config.sops.secrets."user/paulPass".path; 
        };
    };

    nix.settings.trusted-users = [ "paul" ];
}
