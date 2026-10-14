{inputs, ...}: {
  flake.nixosModules.system3-omnigraph-worker = {
    pkgs,
    lib,
    ...
  }: {
    imports = [inputs.system3-omnigraph-latest.nixosModules.system3-omnigraph-worker];

    services.system3-omnigraph-worker.package =
      lib.mkDefault inputs.system3-omnigraph-latest.packages.${pkgs.stdenv.hostPlatform.system}.system3-stage-omnigraph;
  };
}
