{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
        sops-nix.url = "github:Mic92/sops-nix";
        disko = {
            url = "github:nix-community/disko";
            inputs.nixpkgs.follows = "nixpkgs";
        };
    };
    outputs = { self, nixpkgs, sops-nix, disko }:
    let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
    in {
        devShells.${system}.default = pkgs.mkShell {
            buildInputs = [
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
                    ./hosts/nextcloud/hardware-configuration.nix
                    ./hosts/modules/users.nix
                    disko.nixosModules.disko
                    sops-nix.nixosModules.default
                    {
                        sops.defaultSopsFile = ./hosts/nextcloud/secrets.yaml;
                    }
                ];
            };
        };
    };
}
