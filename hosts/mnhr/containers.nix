{self, ...}: {
  flake.nixosModules.mnhr-containers = {hostname, ...}: {
    imports = [
      self.nixosModules.container-wg-easy
      self.nixosModules.container-immich
      self.nixosModules.container-forgejo # to nix
      self.nixosModules.container-vaultwarden # to nix
      self.nixosModules.container-linkding # to nix
      self.nixosModules.container-audiobookshelf # to nix
      self.nixosModules.container-navidrome # to nix
      self.nixosModules.container-stump # to nix
      self.nixosModules.container-arr-stack
    ];

    services.forgejo-compose = {
      enable = true;
      enable_adguard_rewrite = true;
    };

    services.audiobookshelf-compose = {
      enable = true;
      enable_adguard_rewrite = true;
    };

    services.linkding-compose = {
      enable = true;
      enable_adguard_rewrite = true;
      secrets_file = ../../secrets/${hostname}/linkding.yaml;
    };

    services.stump-compose = {
      enable = true;
      enable_adguard_rewrite = true;
    };
  };
}
