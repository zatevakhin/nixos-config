{pkgs, ...}: {
  programs.kitty = {
    enable = true;
    settings = {
      enable_audio_bell = false;
      dynamic_background_opacity = true;
      cursor_shape = "block";
    };
  };

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
      binding = "<Control><Alt>t";
      command = "${pkgs.kitty}/bin/kitty";
      name = "Spawn Kitty";
    };
  };
}
