{...}: {
  flake.nixosModules.binfmt-aarch64 = {
    pkgs,
    lib,
    ...
  }: {
    boot.binfmt.emulatedSystems = [
      "aarch64-linux"
    ];
  };
}
