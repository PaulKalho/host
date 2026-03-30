{ lib, config, ... }:

let
  cfg = config.services.monitoring.promtail;
in
{
  options.services.monitoring.promtail = {
    enable = lib.mkEnableOption "Promtail log collector";
  };

  config = lib.mkIf cfg.enable {
    services.promtail = {
      enable = true;

      configuration = {
        server = {
          http_listen_port = 9080;
        };

        clients = [
          {
            url = "http://69.69.11.26:3100/loki/api/v1/push";
          }
        ];

        scrape_configs = [
          {
            job_name = "journal";

            journal = {
              max_age = "12h";
            };

            relabel_configs = [
              {
                source_labels = [ "__journal__systemd_unit" ];
                target_label = "unit";
              }
              {
                source_labels = [ "__journal__hostname" ];
                target_label = "host";
              }
            ];
          }
        ];
      };
    };
    users.users.promtail.extraGroups = [ "systemd-journal" ];
  };

}
