{
  description = "My NixOS config Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim/nixos-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=v0.4.1";
    };
  };

  outputs = {
    self,
    nixpkgs,
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

        inputs.sops-nix.nixosModules.sops
        inputs.disko.nixosModules.disko
        inputs.home-manager.nixosModules.default
        inputs.nix-flatpak.nixosModules.nix-flatpak
      ];
    };

    nixosConfigurations.nuke = nixpkgs.lib.nixosSystem {
      specialArgs = {
        inherit inputs;
        username = "zatevakhin";
        hostname = "nuke";
      };

      modules = [
        ./hosts/nuke/configuration.nix

        inputs.sops-nix.nixosModules.sops
      ];
    };
  };
}
