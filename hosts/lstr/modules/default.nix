{self, ...}: {
  flake.nixosModules.lstr-modules = {
    pkgs,
    hostname,
    ...
  }: {
    imports = [
      self.nixosModules."${hostname}-applications"
      self.nixosModules."${hostname}-syncthing"
      self.nixosModules."${hostname}-wireguard"
      self.nixosModules."${hostname}-dnsmasq"
    ];
  };
}
