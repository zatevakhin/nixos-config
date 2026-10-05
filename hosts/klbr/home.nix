{self, ...}: {
  flake.nixosModules.klbr-home = self.lib.mkHome {
    stateVersion = "25.11";
    extraSharedModules = hostname: [
      self.homeModules.gnome
      self.homeModules."${hostname}-git"
      self.homeModules.shell
      self.homeModules.ghostty
    ];
    extraUserConfig = {
      home.sessionVariables.XDG_DATA_DIRS = "$XDG_DATA_DIRS/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
    };
  };
}
