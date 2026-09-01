{self, ...}: {
  flake.nixosModules.arar-containers = {
    config,
    lib,
    ...
  }: {
    imports = [
      self.nixosModules.container-calibre-web
      self.nixosModules.container-paperless-ngx
      self.nixosModules.container-vaultwarden
    ];

    config.systemd.services.vaultwarden-compose.environment = {
      VAULTWARDEN_DATA_LOCATION = lib.mkForce "/mnt/storage/.services/vaultwarden/data";
    };
  };
}
