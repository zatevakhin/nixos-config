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
      systems = ["x86_64-linux" "aarch64-linux"];
      perSystem = {pkgs, ...}: {
        formatter = pkgs.alejandra;

        devShells.default = pkgs.mkShell {
          packages = [pkgs.git pkgs.git-agecrypt];
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

    nix-flatpak = {
      url = "github:gmodena/nix-flatpak/?ref=v0.7.0";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    nixpkgs-otelite.url = "github:NixOS/nixpkgs/pull/557742/head";

    # MCPs
    searxng-mcp.url = "github:zatevakhin/searxng-mcp";

    notsecrets = {
      url = "git+ssh://git@forgejo.homeworld.lan:2222/zatevakhin/nixos-notsecrets.git";
      flake = false;
    };
  };
}
