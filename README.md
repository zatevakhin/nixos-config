# nixos-config

NixOS flake for this fleet. `flake-parts` loads `hosts/` and `modules/` through `import-tree`.

Evaluation needs SSH access to the private `notsecrets` input. A Git flake only sees tracked files, so `git add` new files before building. Staging is enough; a commit is not required.

## Layout

```
hosts/<name>/   host entrypoint, configuration, hardware, host-only modules
modules/        shared NixOS features, Home Manager, containers, services
secrets/        SOPS files, plus git-agecrypt files for the installer
flake.nix
.sops.yaml
```

## Hosts

| Host | User | Platform |
| --- | --- | --- |
| `arar` | `zatevakhin` | `aarch64-linux` |
| `flkr` | `ivan` | `x86_64-linux` |
| `klbr` | `ivan` | `x86_64-linux` |
| `lstr` | `ivan` | `x86_64-linux` |
| `mnhr` | `zatevakhin` | `aarch64-linux` |
| `sapr` | `zatevakhin` | `x86_64-linux` |
| `stcr` | `zatevakhin` | `x86_64-linux` |
| `sys3` | `aya` | `aarch64-linux` |
| `iso` | — | installer image |

## Format

Alejandra is the flake formatter.

```sh
nix fmt -- path/to/file.nix
```

`nix fmt` with no arguments reads stdin.

## Deploy

From the repository root:

```sh
sudo nixos-rebuild switch --flake .#HOST
nixos-rebuild switch --target-host root@HOST --flake .#HOST
nixos-rebuild switch --target-host root@HOST --build-host root@BUILD_HOST --flake .#HOST
```

`build` does not activate. `test` activates without changing the boot default. Do not run parallel rebuilds that share one `result` symlink.

## Install

These commands partition and format the target. Read that host's `hardware.nix` and confirm the disk before running them.

Prepare an SSH host key that can decrypt the host's SOPS files. `extra-files/` is gitignored.

```sh
mkdir -p extra-files/HOST/etc/ssh
chmod 700 extra-files/HOST/etc/ssh
ssh-keygen -t ed25519 -N '' -f extra-files/HOST/etc/ssh/ssh_host_ed25519_key
chmod 600 extra-files/HOST/etc/ssh/ssh_host_ed25519_key

nix run github:nix-community/nixos-anywhere -- \
  --flake .#HOST \
  --target-host root@TARGET \
  --extra-files extra-files/HOST
```

`etc/ssh/...` inside `extra-files/HOST` lands at `/etc/ssh/...` on the installed system. Reinstalls should reuse the existing host key unless the SOPS recipients are updated first.

Local disko install, from a live system with this repo available:

```sh
sudo nix run github:nix-community/disko#disko-install -- \
  --flake .#HOST --disk main /dev/DISK
```

`main` must match the disk name in that host's disko config. The host key and SOPS access still have to be in place before the installed system boots.

## Installer ISO

Decrypt `secrets/iso/` with git-agecrypt before building. The image embeds that SSH host key and Tor onion identity. Do not publish the ISO or upload its closure to a public cache.

```sh
nix build .#nixosConfigurations.iso.config.system.build.isoImage
ls result/iso/
```

SSH accepts the `klbr` and `ntgh` keys from `notsecrets` for `root` and `nixos`. Password authentication is disabled. Tor maps onion port 22 to `127.0.0.1:22`. Do not boot two copies at once; they share one onion identity.

```sh
sudo cat /run/tor/onion/ssh/hostname
```

## Secrets

SOPS rules and age recipients are in `.sops.yaml`. Host secrets live under `secrets/<host>/`. Do not commit decrypted keys or `extra-files/`.

Installer identity files are git-agecrypt. `nix develop` sets `core.hooksPath` to `.githooks`, so the pre-commit check runs after that. `nix shell` does not run the shell hook.
