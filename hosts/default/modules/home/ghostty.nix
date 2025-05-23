{pkgs, ...}: {
  # NOTE: Not used due to issues with terminfo
  # https://github.com/ghostty-org/ghostty/discussions/2701
  # https://ghostty.org/docs/help/terminfo
  # https://gist.github.com/alexjsteffen/867c9688be84de4acacbbf18afe7dab1
  programs.zsh.initContent = ''
  '';

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      theme = "Kanagawa Wave";
      font-size = 11;
      font-thicken = true;
      font-family = "FiraCode Nerd Font";
      window-decoration = true;
      gtk-titlebar = false;
      gtk-adwaita = false;
      mouse-scroll-multiplier = 0.5;
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
      command = "${pkgs.ghostty}/bin/ghostty";
      name = "Spawn Ghostty";
    };
  };
}
