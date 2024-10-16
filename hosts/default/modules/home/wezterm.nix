{...}: {
  programs.wezterm = {
    enable = true;
    enableZshIntegration = true;

    extraConfig = ''
      local wezterm = require 'wezterm'
      local config = {}

      config.font = wezterm.font 'FiraCode Nerd Font Mono'
      config.font_size = 10.0
      config.enable_tab_bar = false
      config.color_scheme = 'Catppuccin Mocha'
      config.color_scheme = 'Afterglow'

      return config
    '';
  };

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
      binding = "<Control><Alt>t";
      command = "wezterm";
      name = "Spawn WezTerm";
    };
  };
}
