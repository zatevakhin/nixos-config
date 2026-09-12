{self, ...}: {
  flake.homeModules.shell = {...}: {
    imports = [
      self.homeModules.zsh
      self.homeModules.git
      self.homeModules.helix
    ];
  };
}
