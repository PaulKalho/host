{ lib, pkgs, ... }: 
let
    paulKey = builtins.readFile ../../keys/paulkalhorn.pub;
in {
    users = {
        # TODO: also set a password from the secrets.yaml
        users.paul = {
            isNormalUser = true;
            shell = pkgs.zsh;
            extraGroups = [ "wheel" ];
            openssh.authorizedKeys.keys = [ paulKey ]; 
        };
        # TODO: setup a root user        
   };
    nix.settings.trusted-users = [ "paul" ];
}
