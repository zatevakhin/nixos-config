{...}: {
  services.flameshot = {
    enable = true;
    settings.General = {
      showStartupLaunchMessage = false;
      disabledTrayIcon = false;
      saveLastRegion = false;
    };
  };

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "Print";
      command = "flameshot gui";
      name = "Flameshot";
    };

    "org/gnome/desktop/notifications/application/org-flameshot-flameshot" = {
      enable = false;
    };
  };
}
