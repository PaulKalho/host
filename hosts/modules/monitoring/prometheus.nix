{ lib, config, ... }:

let
  cfg = config.services.monitoring.prometheus;
in
{
  options.services.monitoring.prometheus = {
    enable = lib.mkEnableOption "Prometheus";

    scrapeTargets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };

    blackboxTargets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    services.prometheus = {
      enable = true;

      scrapeConfigs = [
        {
          job_name = "nodes";

          static_configs = [
            {
              targets = cfg.scrapeTargets;
            }
          ];
          # TODO: Relabel configs?
        }
        {
          job_name = "blackbox";

          metrics_path = "/probe";

          params = {
            module = [ "http_2xx" ];
          };

          static_configs = [
            {
              targets = cfg.blackboxTargets;
            }
          ];

          relabel_configs = [
            {
              source_labels = [ "__address__" ];
              target_label = "__param_target";
            }
            {
              source_labels = [ "__param_target" ];
              target_label = "instance";
            }
            {
              target_label = "__address__";
              replacement = "127.0.0.1:9115";
            }
          ];
        }

      ];
    };
  };
}
