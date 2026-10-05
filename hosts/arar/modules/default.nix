{self, ...}: {
  flake.nixosModules.arar-modules = {
    pkgs,
    hostname,
    ...
  }: {
    imports = [
      self.nixosModules."${hostname}-keepalived"
      self.nixosModules."${hostname}-syncthing"
      self.nixosModules."${hostname}-traefik"
    ];
  };
}
