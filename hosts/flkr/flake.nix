{
  description = "flkr host configuration";

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
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    notsecrets = {
      url = "git+ssh://git@forgejo.homeworld.lan:2222/zatevakhin/nixos-notsecrets.git";
      flake = false;
    };
    searxng-mcp.url = "github:zatevakhin/searxng-mcp";
    nix-flatpak.url = "github:gmodena/nix-flatpak/?ref=v0.7.0";
    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixpkgs-otelite.url = "github:NixOS/nixpkgs/pull/557742/head";
  };
}
