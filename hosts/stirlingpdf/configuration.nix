{
  pkgs,
  lib,
  ...
}:
{
  nixpkgs.hostPlatform = "x86_64-linux";

  services.stirling-pdf = {
    enable = true;
    package = pkgs.unstable.stirling-pdf;

    environment = {
      SERVER_PORT = 8080;
      SECURITY_ENABLELOGIN = "true";
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
