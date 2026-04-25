{self, ...}: {
  flake.nixosModules.sapr-containers = {...}: {
    imports = [
      self.nixosModules.container-jellyfin
    ];
  };
}
