{
  description = "sys3 host configuration";

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
    searxng-mcp.url = "github:zatevakhin/searxng-mcp";
    jetpack = {
      url = "github:anduril/jetpack-nixos/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    system3-latest = {
      url = "git+ssh://git@github.com/zatevakhin/system3?rev=d37dad018d7d0abef731db82a20a1a3ee2801d5c";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    system3-omnigraph-latest = {
      url = "git+ssh://git@github.com/zatevakhin/system3-omngraph?ref=refs/pull/1/head&rev=5307d16087e9c3cb4bba8fa006f9dcaed17ce1eb";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
