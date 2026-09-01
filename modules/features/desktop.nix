{self, ...}: {
  flake.nixosModules.desktop = {...}: {
    imports = [
      self.nixosModules.networkmanager
      self.nixosModules.virtual-camera
      self.nixosModules.search-mcp
      self.nixosModules.bluetooth
      self.nixosModules.graphics
      self.nixosModules.appimage
      self.nixosModules.logitech
      self.nixosModules.printers
      self.nixosModules.flatpak
      self.nixosModules.gaming
      self.nixosModules.gnome
      self.nixosModules.audio
    ];
  };
}
