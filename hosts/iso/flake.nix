{
  description = "iso host configuration";

  outputs = inputs:
    import ../../lib/mk-host-flake.nix {
      inherit inputs;
      hostDir = ./.;
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
    import-tree.url = "github:vic/import-tree";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    notsecrets = {
      url = "git+ssh://git@forgejo.homeworld.lan:2222/zatevakhin/nixos-notsecrets.git";
      flake = false;
    };
  };
}
