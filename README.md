### Host

This is the repository where I define all my important hosts on my server.

### How-To

Install nix on your system.

To jump into the devshell: `nix develop`

1) To encrypt and decrypt files you have to create a PGP Key.
Edit the .sops.yaml accordingly.

2) Update the sops keys
sops updatekeys {path/to/any/secrets.yaml}

> We use [opentofu](https://opentofu.org/) as our IaC tool.
3) To provision the VM for the host, find it within: `/infra`

```bash
    tofu init
    tofu apply
```

4) TODO: Deploy the Nixos-anywhere configuration to the provisioned VM
