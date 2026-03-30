{ ... }:
{
  imports = [
    ../modules/base.nix
    ../modules/networking.nix
    ../modules/qemu.nix

    ../modules/monitoring/server.nix
  ];

  deployment = {
    ip = "69.69.11.26";
    gateway = "69.69.11.1";
    hostname = "monitoring";
    domain = "monitoring.kalhorn.org";
    extraTCPPorts = [
      3000
      3100
    ];
  };

  services.monitoring.server = {
    enable = true;
    grafana.enable = true;
    blackbox.enable = true;
    loki.enable = true;

    scrapeTargets = [
      "69.69.11.23:9100"
      "69.69.11.24:9100"
      "69.69.11.25:9100"
    ];

    blackboxTargets = [
      "https://vault.kalhorn.org"
      "https://cloud.kalhorn.org"
      "https://pdf.kalhorn.org"
    ];
  };
  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}
