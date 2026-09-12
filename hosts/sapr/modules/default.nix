{self, ...}: {
  flake.nixosModules.sapr-modules = {
    pkgs,
    hostname,
    ...
  }: {
    imports = [
      self.nixosModules."${hostname}-keepalived"
      self.nixosModules."${hostname}-traefik"
      # self.nixosModules."${hostname}-nfs"
    ];
  };
}
