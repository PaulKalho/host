{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      sops-nix,
      disko,
    }:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      unstable = nixpkgs-unstable.legacyPackages.${system};

      overlay-unstable = final: prev: {
        unstable = unstable;
      };
    in
    {
      devShells.${system}.default = pkgs.mkShell {
        packages = [
          pkgs.sops
          pkgs.opentofu
          pkgs.git
          pkgs.nixos-anywhere
          pkgs.nixos-rebuild
          pkgs.ssh-to-age
          pkgs.mkpasswd
          pkgs.borgbackup
        ];
      };

      nixosConfigurations = {
        nextcloud = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/nextcloud/configuration.nix
            ./hosts/nextcloud/disk-configuration.nix
            ./hosts/modules/users.nix
            disko.nixosModules.disko
            sops-nix.nixosModules.default
            {
              sops.defaultSopsFile = ./hosts/nextcloud/secrets.yaml;
            }
          ];
        };

        vaultwarden = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            {
              nixpkgs.overlays = [ overlay-unstable ];
            }
            ./hosts/vaultwarden/configuration.nix
            ./hosts/vaultwarden/disk-configuration.nix
            ./hosts/modules/users.nix
            disko.nixosModules.disko
            sops-nix.nixosModules.default
            {
              sops.defaultSopsFile = ./hosts/vaultwarden/secrets.yaml;
            }
          ];
        };

        stirlingpdf = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            {
              nixpkgs.overlays = [ overlay-unstable ];
            }
            ./hosts/stirlingpdf/configuration.nix
            ./hosts/stirlingpdf/disk-configuration.nix
            ./hosts/modules/users.nix
            disko.nixosModules.disko
            sops-nix.nixosModules.default
            {
              sops.defaultSopsFile = ./hosts/stirlingpdf/secrets.yaml;
            }
          ];
        };

        monitoring = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            {
              nixpkgs.overlays = [ overlay-unstable ];
            }
            ./hosts/monitoring/configuration.nix
            ./hosts/monitoring/disk-configuration.nix
            ./hosts/modules/users.nix
            disko.nixosModules.disko
            sops-nix.nixosModules.default
            {
              sops.defaultSopsFile = ./hosts/monitoring/secrets.yaml;
            }
          ];
        };

        minecraft = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            {
              nixpkgs.overlays = [ overlay-unstable ];
            }
            ./hosts/minecraft/configuration.nix
            ./hosts/minecraft/disk-configuration.nix
            ./hosts/modules/users.nix
            disko.nixosModules.disko
            sops-nix.nixosModules.default
            {
              sops.defaultSopsFile = ./hosts/stirlingpdf/secrets.yaml;
            }
          ];
        };
      };
    };
}
