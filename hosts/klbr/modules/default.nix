{self, ...}: {
  flake.nixosModules.klbr-modules = {
    pkgs,
    hostname,
    ...
  }: {
    imports = [
      self.nixosModules."${hostname}-wireguard"
    ];
  };
}
