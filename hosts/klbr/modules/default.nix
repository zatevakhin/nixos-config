{self, ...}: {
  flake.nixosModules.klbr-modules = {
    pkgs,
    hostname,
    ...
  }: {
    imports = [
    ];
  };
}
