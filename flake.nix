{
  description = "My NixOS config Flake";

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
      imports = [
        (inputs.import-tree [
          ./hosts
          ./modules
        ])

        inputs.home-manager.flakeModules.home-manager
      ];
      systems = ["x86_64-linux" "aarch64-linux" "aarch64-darwin"];
      perSystem = {pkgs, ...}: {
        formatter = pkgs.alejandra;

        devShells.default = pkgs.mkShell {
          packages = [pkgs.git pkgs.git-agecrypt pkgs.just pkgs.alejandra];
          shellHook = ''
            repo=$(git rev-parse --show-toplevel 2>/dev/null || true)
            if [[ -n $repo ]]; then
              git -C "$repo" config core.hooksPath .githooks
            fi
          '';
        };
      };
    };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";

    import-tree.url = "github:vic/import-tree";

    jetpack = {
      url = "github:anduril/jetpack-nixos/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=v0.7.0";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixpkgs-otelite.url = "github:NixOS/nixpkgs/pull/557742/head";

    voxtype = {
      url = "github:peteonrails/voxtype/v1.1.0";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    # MCPs
    searxng-mcp.url = "github:zatevakhin/searxng-mcp";

    # Revisions nano was already running. Do not float these.
    system3 = {
      url = "git+ssh://git@github.com/zatevakhin/system3?rev=344483d3967f69f2c1a8bb74823da8208d880241";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Current main for sys3. Do not point nano at this.
    system3-latest = {
      url = "git+ssh://git@github.com/zatevakhin/system3?rev=38edf939de53cb54a5169a43fa9b484166d1d4c7";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    system3-omnigraph = {
      url = "git+ssh://git@github.com/zatevakhin/system3-omngraph?rev=84081d3251fa0574962fdebb1257a5559380786e";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    notsecrets = {
      url = "git+ssh://git@forgejo.homeworld.lan:2222/zatevakhin/nixos-notsecrets.git";
      flake = false;
    };
  };
}
