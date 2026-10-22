{
  description = "Fleet development tools";

  outputs = inputs:
    inputs.flake-parts.lib.mkFlake {inherit inputs;} {
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
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };
}
