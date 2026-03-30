{ lib, config, ... }:

let
  cfg = config.services.monitoring.agent;
in
{
  options.services.monitoring.agent = {
    enable = lib.mkEnableOption "monitoring agent";
  };

  config = lib.mkIf cfg.enable {
    services.prometheus.exporters.node = {
      enable = true;
      port = 9100;
    };
  };
}
