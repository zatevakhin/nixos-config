{...}: {
  services.copyq.enable = true;

  home.file.".config/copyq/copyq.conf".text = ''
    [Options]
    maxitems=2000
    tabs=&clipboard
    always_on_top=true
    confirm_exit=false
    close_on_unfocus=true
    activate_pastes=false
    disable_tray=false
  '';

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
      binding = "<Alt>F1";
      command = "copyq toggle";
      name = "CopyQ";
    };

    "org/gnome/desktop/notifications/application/com-github-hluk-copyq" = {
      enable = false;
    };
  };
}
