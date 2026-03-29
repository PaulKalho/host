# hosts/modules/base.nix
{ lib, pkgs, ... }:
{
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  programs.zsh.enable = true;

  environment.systemPackages = with pkgs; [
    htop
    tree
    tmux
  ];

  services.nginx.enable = true;

  services.openssh = {
    enable = true;
    settings.PermitRootLogin = lib.mkForce "prohibit-password";
    settings.PubkeyAuthentication = "yes";
    settings.PasswordAuthentication = false;
  };

  system.stateVersion = "24.11";
}
