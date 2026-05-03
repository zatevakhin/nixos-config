{self, ...}: {
  flake.nixosModules.desktop = {...}: {
    imports = [
      self.nixosModules.networkmanager
      self.nixosModules.bluetooth
      self.nixosModules.graphics
      self.nixosModules.appimage
      self.nixosModules.logitech
      self.nixosModules.flatpak
      self.nixosModules.searxng
      self.nixosModules.gaming
      self.nixosModules.gnome
      self.nixosModules.audio
    ];
  };
}
