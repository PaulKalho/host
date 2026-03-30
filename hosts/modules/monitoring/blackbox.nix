{ lib, config, ... }:
let
  cfg = config.services.monitoring.blackbox;
in
{
  options.services.monitoring.blackbox = {
    enable = lib.mkEnableOption "blackbox exporter";

    targets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "URLs to probe";
    };
  };

  config = lib.mkIf cfg.enable {
    services.prometheus.exporters.blackbox = {
      enable = true;
      port = 9115;

      configFile = builtins.toFile "blackbox.yml" ''
        modules:
          http_2xx:
            prober: http
            timeout: 5s
            http:
              preferred_ip_protocol: ip4
              ip_protocol_fallback: true
              valid_status_codes: [200, 401]
              method: GET
              follow_redirects: true
      '';
    };
  };
}
