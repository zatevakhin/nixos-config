{
  description = "My NixOS config Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix-unstable = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager-next = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=v0.6.0";
    };

    stylix = {
      url = "github:danth/stylix/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # MCPs
    searxng-mcp.url = "github:zatevakhin/searxng-mcp";

    # Tools
    beads = {
      url = "github:steveyegge/beads?ref=v0.49.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nix-darwin,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} ({...}: let
      username = "ivan";

      x86Linux = "x86_64-linux";
      armLinux = "aarch64-linux";
      armDarwin = "aarch64-darwin";

      pkgsUnstableFor = system:
        import nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
          overlays = [(import ./modules/overlays/avante-nvim.nix)];
        };
    in {
      systems = [x86Linux armLinux armDarwin];

      flake = {
        /*
        * Installation Instructions:
        *
        * 1. NixOS Installation (using nixos-anywhere for most systems):
        *    - Generate an ISO image if needed:
        *      nix build .#nixosConfigurations.iso.config.system.build.isoImage
        *    - Boot from the generated ISO.
        *    - Prepare extra files with generated SSH keys for the target machine in 'extra-files' directory.
        *    - Run nixos-anywhere for remote installation:
        *      nix run github:nix-community/nixos-anywhere -- --flake .#<machine-id> --target-host root@<machine-ip> --extra-files extra-files
        *
        * 2. NixOS Installation (using disko for specific devices like mnhr):
        *    - Ensure all necessary tools are present in your shell:
        *      nix shell -- nixpkgs#{coreutils-full,dosfstools,f2fs-tools,fscrypt-experimental,gptfdisk,nixos-install-tools,util-linux,neovim}
        *    - Install on the chosen device (e.g., for 'mnhr' on '/dev/mmcblk0'):
        *      nix run 'github:nix-community/disko#disko-install' -- --flake .#mnhr --disk main /dev/mmcblk0
        *
        * 3. Nix-Darwin Installation (for macOS systems like eulr):
        *    - Switch to the nix-darwin configuration:
        *      nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake .#eulr
        *
        * 4. SSH Options (might be needed when working with long hostnames):
        *    - export NIX_SSHOPTS="-o ControlPath=~/.ssh/cm-%r@%h:%p -o ControlMaster=auto -o ControlPersist=10m"
        */

        nixosConfigurations.default = nixpkgs.lib.nixosSystem {
          system = x86Linux;
          specialArgs = {
            inherit inputs username;
            pkgs-unstable = pkgsUnstableFor x86Linux;
            hostname = "baseship";
          };
          modules = [
            ./hosts/default/configuration.nix

            inputs.nixvim.nixosModules.nixvim
            inputs.sops-nix.nixosModules.sops
            inputs.disko.nixosModules.disko
            inputs.home-manager.nixosModules.default
            inputs.nix-flatpak.nixosModules.nix-flatpak
            inputs.stylix.nixosModules.stylix
          ];
        };

        nixosConfigurations.lstr = nixpkgs.lib.nixosSystem {
          system = x86Linux;
          specialArgs = {
            inherit inputs username;
            pkgs-unstable = pkgsUnstableFor x86Linux;
            system = x86Linux;
            hostname = "lstr";
          };

          modules = [
            ./hosts/lstr/configuration.nix

            inputs.nixvim.nixosModules.nixvim
            inputs.sops-nix.nixosModules.sops
            inputs.disko.nixosModules.disko
            inputs.home-manager.nixosModules.default
            inputs.nix-flatpak.nixosModules.nix-flatpak
            inputs.stylix.nixosModules.stylix
            inputs.searxng-mcp.nixosModules.searxng-mcp
          ];
        };

        nixosConfigurations.flkr = nixpkgs.lib.nixosSystem {
          system = x86Linux;
          specialArgs = {
            inherit inputs username;
            pkgs-unstable = pkgsUnstableFor x86Linux;
            system = x86Linux;
            hostname = "flkr";
          };

          modules = [
            ./hosts/flkr/configuration.nix

            inputs.sops-nix.nixosModules.sops
            inputs.home-manager.nixosModules.default
            inputs.nix-flatpak.nixosModules.nix-flatpak
            inputs.nixvim.nixosModules.nixvim
          ];
        };

        nixosConfigurations.klbr = nixpkgs.lib.nixosSystem {
          system = x86Linux;
          specialArgs = {
            inherit inputs username;
            pkgs-unstable = pkgsUnstableFor x86Linux;
            system = x86Linux;
            hostname = "klbr";
          };

          modules = [
            ./hosts/klbr/configuration.nix

            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
            inputs.nixvim.nixosModules.nixvim
            inputs.stylix.nixosModules.stylix
            inputs.home-manager.nixosModules.default
            inputs.nix-flatpak.nixosModules.nix-flatpak
            inputs.nixos-hardware.nixosModules.framework-amd-ai-300-series
          ];
        };

        nixosConfigurations.arar = nixpkgs.lib.nixosSystem {
          system = armLinux;
          specialArgs = {
            inherit inputs;
            username = "zatevakhin";
            hostname = "arar";
          };

          modules = [
            ./hosts/arar/configuration.nix

            inputs.sops-nix.nixosModules.sops
          ];
        };

        nixosConfigurations.mnhr = nixpkgs-unstable.lib.nixosSystem {
          system = armLinux;
          specialArgs = {
            inherit inputs;
            username = "zatevakhin";
            hostname = "mnhr";
          };

          modules = [
            ./hosts/mnhr/configuration.nix

            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
          ];
        };

        nixosConfigurations.sapr = nixpkgs.lib.nixosSystem {
          system = x86Linux;
          specialArgs = {
            inherit inputs;
            username = "zatevakhin";
            hostname = "sapr";
          };

          modules = [
            ./hosts/sapr/configuration.nix

            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
          ];
        };

        nixosConfigurations.stcr = nixpkgs.lib.nixosSystem {
          system = x86Linux;
          specialArgs = {
            inherit inputs;
            username = "zatevakhin";
            hostname = "stcr";
          };

          modules = [
            ./hosts/stcr/configuration.nix

            inputs.disko.nixosModules.disko
            inputs.sops-nix.nixosModules.sops
          ];
        };

        # qemu-system-x86_64 -m 2048M --drive "media=cdrom,file=${NIXOS_CONFIG_ISO},format=raw,readonly=on" -net nic -net user -nographic -monitor pty -serial stdio -drive file=nixos-test.qcow2,format=qcow2,if=virtio -smp 4
        nixosConfigurations.iso = nixpkgs.lib.nixosSystem {
          system = x86Linux;
          modules = [
            "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            ./hosts/iso/configuration.nix
          ];
        };
      };
    });
}
