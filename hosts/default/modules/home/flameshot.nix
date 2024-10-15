{pkgs, ...}: let
  flameshot-gui = pkgs.writeShellScriptBin "flameshot-gui" "${pkgs.flameshot}/bin/flameshot gui";
in {
  # BUG: https://flameshot.org/docs/guide/wayland-help/#gnome-shortcut-does-not-trigger-flameshot
  # FIX: https://github.com/flameshot-org/flameshot/issues/3365#issuecomment-1868580715

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
      command = "${flameshot-gui}/bin/flameshot-gui";
      name = "Flameshot";
    };

    "org/gnome/desktop/notifications/application/org-flameshot-flameshot" = {
      enable = false;
    };
  };
}
