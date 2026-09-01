{self, ...}: {
  flake.nixosModules.mnhr-modules = {
    pkgs,
    hostname,
    ...
  }: {
    imports = [
      self.nixosModules."${hostname}-keepalived"
      self.nixosModules."${hostname}-syncthing"
      self.nixosModules."${hostname}-traefik"
      self.nixosModules."${hostname}-nfs"
    ];
  };
}
