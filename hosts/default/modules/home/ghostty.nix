{pkgs, ...}: {
  # NOTE: Not used due to issues with terminfo
  # https://github.com/ghostty-org/ghostty/discussions/2701
  # https://ghostty.org/docs/help/terminfo
  programs.zsh.initExtra = ''
    if [[ "$TERM_PROGRAM" == "ghostty" ]]; then
      export TERM=xterm-256color
    fi
  '';

  programs.ghostty = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      theme = "Kanagawa Wave";
      font-size = 11;
      font-family = "FiraCode Nerd Font";
      window-decoration = "none";
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
