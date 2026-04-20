{ ... }:
{
  imports = [
    ../modules/base.nix
    ../modules/networking.nix
    ../modules/qemu.nix
  ];

  nixpkgs.config.allowUnfree = true;

  deployment = {
    ip = "69.69.11.27";
    gateway = "69.69.11.1";
    hostname = "minecraft";
    domain = "minecraft.kalhorn.org";
    extraTCPPorts = [
      43000
    ];
  };

  services.minecraft-server = {
    enable = true;
    eula = true;
    openFirewall = true;
    declarative = true;
    whitelist = {
      Xpro5 = "d55d0388-fbd4-4f80-b4eb-052338f09fea";
      KingPJkmincraft = "36ddb3c3-1935-4dab-935f-110f224929f8";
    };
    serverProperties = {
      server-port = 43000;
      difficulty = 3;
      gamemode = 1;
      max-players = 5;
      motd = "Minecraft server!";
      white-list = true;
      allow-cheats = true;
    };
    jvmOpts = "-Xms2048M -Xmx2048M";
  };

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
}
