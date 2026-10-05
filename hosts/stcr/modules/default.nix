{self, ...}: {
  flake.nixosModules.stcr-modules = {hostname, ...}: {
    imports = [
      self.nixosModules."${hostname}-wireguard"
    ];
  };
}
