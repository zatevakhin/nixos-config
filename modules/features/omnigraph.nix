{...}: {
  flake.nixosModules.omnigraph = {
    imports = [../../flakes/omnigraph/module.nix];
  };
}
