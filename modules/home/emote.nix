{...}: {
  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/emote/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/emote" = {
      binding = "<Ctrl><Alt>E";
      command = "flatpak run com.tomjwatson.Emote";
      name = "Emote";
    };
  };
}
