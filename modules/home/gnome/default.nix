{self, ...}: {
  flake.homeModules.gnome = {...}: {
    imports = [
      self.homeModules.dconf
      self.homeModules.gradia
      self.homeModules.associations
      self.homeModules.gnome-extensions
    ];
  };
}
