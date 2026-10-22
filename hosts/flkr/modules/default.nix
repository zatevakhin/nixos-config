{self, ...}: {
  flake.nixosModules.flkr-modules = {
    pkgs,
    hostname,
    ...
  }: {
    imports = [
      self.nixosModules."${hostname}-wireguard"
      self.nixosModules."${hostname}-dnsmasq"
    ];
  };
}
