{
  description = "nano host configuration";

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
    # Keep NANO on the revisions it already runs.
    system3 = {
      url = "git+ssh://git@github.com/zatevakhin/system3?rev=344483d3967f69f2c1a8bb74823da8208d880241";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    system3-omnigraph = {
      url = "git+ssh://git@github.com/zatevakhin/system3-omngraph?rev=84081d3251fa0574962fdebb1257a5559380786e";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
