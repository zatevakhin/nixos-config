{self, ...}: {
  flake.nixosModules.desktop = {...}: {
    imports = [
      self.nixosModules.gnome
      self.nixosModules.audio
      self.nixosModules.graphics
      self.nixosModules.bluetooth
      self.nixosModules.networkmanager
      self.nixosModules.logitech
      self.nixosModules.gaming
      self.nixosModules.searxng
    ];
  };
}
