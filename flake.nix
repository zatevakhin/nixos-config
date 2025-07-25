{
  description = "My NixOS config Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

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
      url = "github:nix-community/home-manager/release-25.05";
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

    mcphub-nvim.url = "github:ravitemer/mcphub.nvim";
    mcp-hub.url = "github:ravitemer/mcp-hub";

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=v0.6.0";
    };

    stylix = {
      url = "github:danth/stylix/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nix-darwin,
    nixpkgs-unstable,
    ...
  } @ inputs: let
    username = "ivan";
    system = "x86_64-linux";

    pkgs = import nixpkgs {
      system = "${system}";
      config.allowUnfree = true;
    };

    pkgs-unstable = import nixpkgs-unstable {
      system = "${system}";
      config.allowUnfree = true;
      overlays = [(import ./modules/overlays/avante-nvim.nix)];
    };
  in {
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
    */

    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        inherit username;
        inherit pkgs-unstable;
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
      specialArgs = {
        inherit inputs;
        inherit username;
        inherit pkgs-unstable;
        inherit system;
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
      ];
    };

    nixosConfigurations.flkr = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        inherit username;
        inherit pkgs-unstable;
        inherit system;
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
      specialArgs = {
        inherit inputs;
        username = "zatevakhin";
        hostname = "klbr";
      };

      modules = [
        ./hosts/klbr/configuration.nix

        inputs.disko.nixosModules.disko
        inputs.sops-nix.nixosModules.sops
      ];
    };

    nixosConfigurations.arar = nixpkgs.lib.nixosSystem {
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

    darwinConfigurations.eulr = nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit self;
        inherit inputs;
        inherit username;
        hostname = "eulr";
      };

      modules = [
        ./hosts/eulr/configuration.nix

        inputs.nixvim.nixDarwinModules.nixvim
        inputs.sops-nix-unstable.darwinModules.sops
        inputs.home-manager-next.darwinModules.home-manager
        inputs.nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            # Install Homebrew under the default prefix
            enable = true;

            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;

            # User owning the Homebrew prefix
            user = username;

            # Automatically migrate existing Homebrew installations
            autoMigrate = true;
          };
        }
      ];
    };

    nixosConfigurations.iso = nixpkgs.lib.nixosSystem {
      system = "${system}";
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ./hosts/iso/configuration.nix
      ];
    };
  };
}
