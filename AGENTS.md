# My NixOS fleet

This repo describes my (Ivan's) fleet of NixOS-powered machines.

Edit this file only with direct permission from the human operator. If you think edits are needed, think twice and then ask if they are still needed.

## Commit style
Follow the repo's commit style. The repo uses conventional commits.

## Architecture
Dendritic: `flake-parts` + `import-tree` over `./hosts` and `./modules`. Each Nix file is a flake-parts module that declares its own `flake.nixosConfigurations.*`, `flake.nixosModules.*`, or `flake.homeModules.*`.

`flake.*` names must be unique (duplicate keys last-wins; collisions are a defect). One `flake.nixosModules.*` or `flake.homeModules.*` per file.

A host `default.nix` uses `self.lib.mkHost` and lists only that host's modules. Always-on base modules and disko/sops live in `mkHost`. Extra-input NixOS modules belong in the feature file that needs them.

If a change would undo this, stop and tell the user.

## Secrets policy
- Don't access secrets. You may inspect only the shape of objects from encrypted files. Attempts to decrypt secrets will be flagged and the session will be stopped immediately.
- The `notsecrets` input in the flake contains only low-value secrets, but you may still inspect only object shape.
