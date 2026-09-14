{
  description = "Omnigraph graph database — CLI and server";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    ...
  }:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "aarch64-linux"
        "x86_64-linux"
      ];

      flake = {
        nixosModules.default = self.nixosModules.omnigraph;
        nixosModules.omnigraph = import ./module.nix;
      };

      perSystem = {
        pkgs,
        ...
      }: let
        omnigraph = pkgs.callPackage ./package.nix {};
      in {
        packages = {
          default = omnigraph.combined;
          omnigraph-cli = omnigraph.omnigraph-cli;
          omnigraph-server = omnigraph.omnigraph-server;
        };

        formatter = pkgs.alejandra;
      };
    };
}
