{ config, lib, ... }:

let
  d = config.deployment;
in
{
  options.deployment = {
    ip = lib.mkOption {
      type = lib.types.str;
      description = "IPv4 address of the host";
    };

    gateway = lib.mkOption {
      type = lib.types.str;
      description = "Default gateway";
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      description = "Hostname of the machine";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Domain name";
    };

    extraTCPPorts = lib.mkOption {
      type = lib.types.listOf lib.types.int;
      default = [ ];
      description = "Additional allowed TCP ports";
    };
  };

  config = {
    networking = {
      useDHCP = false;

      hostName = d.hostname;
      domain = d.domain;

      interfaces.eth0.ipv4.addresses = [
        {
          address = d.ip;
          prefixLength = 24;
        }
      ];

      defaultGateway = d.gateway;

      nameservers = [
        "8.8.8.8"
        "8.8.4.4"
      ];

      firewall = {
        enable = true;
        allowedTCPPorts = [
          80
          443
        ]
        ++ (config.deployment.extraTCPPorts or [ ]);
      };
    };
  };
}
