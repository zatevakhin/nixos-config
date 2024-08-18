{pkgs, ...}: {
  services.copyq.enable = true;

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "F12";
      command = "${pkgs.tilix}/bin/tilix --quake";
      name = "Tilix";
    };
  };
}
