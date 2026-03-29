{ pkgs, ... }:
{
  imports = [
    ../modules/base.nix
    ../modules/networking.nix
    ../modules/qemu.nix
  ];

  deployment = {
    ip = "69.69.11.25";
    gateway = "69.69.11.1";
    hostname = "stirlingpdf";
    domain = "pdf.kalhorn.org";
    extraTCPPorts = [ 8080 ];
  };

  services.stirling-pdf = {
    enable = true;
    package = pkgs.unstable.stirling-pdf;

    environment = {
      SERVER_PORT = 8080;
      SECURITY_ENABLELOGIN = "true";
    };
  };

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}
