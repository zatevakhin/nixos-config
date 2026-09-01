{self, ...}: {
  flake.nixosModules.sapr-containers = {...}: {
    imports = [
      self.nixosModules.container-audiobookshelf
      self.nixosModules.container-vaultwarden
      self.nixosModules.container-navidrome
      self.nixosModules.container-jellyfin
      self.nixosModules.container-linkding
      self.nixosModules.container-forgejo
      self.nixosModules.container-immich
    ];
  };
}
