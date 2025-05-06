{
  description = "My NixOS config Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
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
      url = "github:nix-community/home-manager/release-24.11";
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
      url = "github:danth/stylix/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    nixpkgs-unstable,
    nix-darwin,
    nix-homebrew,
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
    };
  in {
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

    nixosConfigurations.falke = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        inherit username;
        inherit pkgs-unstable;
        hostname = "falke";
      };

      modules = [
        ./hosts/falke/configuration.nix

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

    # NOTE: Install should be performed using commands below.
    # 1. Ensure that all tools are present.
    # >> nix shell -- nixpkgs#{coreutils-full,dosfstools,f2fs-tools,fscrypt-experimental,gptfdisk,nixos-install-tools,util-linux,neovim}
    # 2. Install on a chosen device.
    # >> nix run 'github:nix-community/disko#disko-install' -- --flake .#mnhr --disk main /dev/mmcblk0
    #
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

    # >> nix --extra-experimental-features "nix-command flakes" run nix-darwin -- switch --flake .#eulr
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
        nix-homebrew.darwinModules.nix-homebrew
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

    # NOTE: Build ISO image with specified configuration.
    # >> nix build .#nixosConfigurations.iso.config.system.build.isoImage
    nixosConfigurations.iso = nixpkgs.lib.nixosSystem {
      system = "${system}";
      modules = [
        "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
        ./hosts/iso/configuration.nix
      ];
    };
  };
}
