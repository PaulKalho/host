### Host

This is the repository where I define all my important hosts on my server.

### How-To

Install nix on your system.

To jump into the devshell: `nix develop`

1) To encrypt and decrypt files you have to create a PGP Key.
Edit the .sops.yaml accordingly.

2) Update the sops keys

```bash
sops updatekeys {path/to/any/secrets.yaml}
```

> We use [opentofu](https://opentofu.org/) as our IaC tool.
3) To provision the VM for the host, find it within: `/infra`

```bash
    tofu init
    tofu apply
```

4) Pregenerate hostkeys

Pregenerate hostkeys using the `hostkeys.sh`. These will be copied to the target-machine.

The script prints an age-key which is created from the public host key.

5) Update sops kes using the age key

Add the age-key to the `.sops.yaml` and run

```bash
sops updatekeys {path/to/any/secrets.yaml}
```

6) Deploy the Nixos-anywhere configuration to the provisioned VM

Don't forget to copy the host keys from the tmp directory to the target.
 
> [!Note]
> I am using nix run github:nix-community/nixos-anywhere here as there seem to be issues with
> the pkgs.nixos-anywhere version when using --extra-files

```bash
nix run github:nix-community/nixos-anywhere -- --flake .#whatever --extra-files tmp/extra-files/ user@ip
```

7) Rebuild if you make any changes to the .nix files

If you make changes to the nix configurations, don't forget to rebuild the system:

```bash
nixos-rebuild switch --flake .#nextcloud --target-host "user@ip"
```
