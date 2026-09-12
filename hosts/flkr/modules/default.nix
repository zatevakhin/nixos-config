{self, ...}: {
  flake.nixosModules.flkr-modules = {
    pkgs,
    hostname,
    ...
  }: {
    imports = [
    ];
  };
}
