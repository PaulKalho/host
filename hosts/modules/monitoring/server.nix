{ lib, config, ... }:

let
  cfg = config.services.monitoring.server;
in
{
  imports = [
    ./prometheus.nix
    ./grafana.nix
    ./blackbox.nix

    ./loki.nix
    ./promtail.nix
  ];

  options.services.monitoring.server = {
    enable = lib.mkEnableOption "central monitoring server";

    scrapeTargets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of Prometheus scrape targets (host:port)";
    };

    blackboxTargets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "List of URLs to probe";
    };

    grafana.enable = lib.mkEnableOption "Grafana UI";
    blackbox.enable = lib.mkEnableOption "Blackbox exporter";
    loki.enable = lib.mkEnableOption "Loki";
  };

  config = lib.mkIf cfg.enable {
    services.monitoring.prometheus = {
      enable = true;
      scrapeTargets = cfg.scrapeTargets;
      blackboxTargets = cfg.blackboxTargets;
    };

    # Grafana
    services.monitoring.grafana.enable = cfg.grafana.enable;
    # Blackbox
    services.monitoring.blackbox.enable = cfg.blackbox.enable;
    # Loki
    services.monitoring.loki.enable = cfg.loki.enable;
  };
}
