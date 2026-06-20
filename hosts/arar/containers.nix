{self, ...}: {
  flake.nixosModules.arar-containers = {...}: {
    imports = [
      self.nixosModules.container-calibre-web
      self.nixosModules.container-paperless-ngx
    ];
  };
}
