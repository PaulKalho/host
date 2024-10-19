{
    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
        sops-nix.url = "github:Mic92/sops-nix";
    };
    outputs = { self, nixpkgs, sops-nix }:
    let
        system = "x86_64-linux";
        pkgs = nixpkgs.legacyPackages.${system};
    in {
        devShells.${system}.default = pkgs.mkShell {
            buildInputs = [
                pkgs.sops
                pkgs.opentofu
            ];
        };

        nixosConfigurations = {
            nextcloud = nixpkgs.lib.nixosSystem {
                system = "x86_64-linux";
                modules = [
                    ./hosts/nextcloud/configuration.nix
                ];
            };
        };
    };
}
