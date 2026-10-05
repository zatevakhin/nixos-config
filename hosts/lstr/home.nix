{self, ...}: {
  flake.nixosModules.lstr-home = self.lib.mkHome {
    stateVersion = "24.05";
    extraSharedModules = hostname: [
      self.homeModules.gnome
      self.homeModules."${hostname}-touchpad"
      self.homeModules."${hostname}-git"
      self.homeModules.copyq
      self.homeModules.shell
      self.homeModules.ghostty
    ];
    extraUserConfig = {username, ...}: {
      sops.age = {
        sshKeyPaths = ["/home/${username}/.ssh/id_ed25519"];
        keyFile = "/home/${username}/.config/sops/age/keys.txt";
      };
      home.sessionVariables.XDG_DATA_DIRS = "$XDG_DATA_DIRS/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share";
    };
  };
}
