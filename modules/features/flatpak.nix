{...}: {
  flake.nixosModules.flatpak = {...}: {
    services.flatpak.enable = true;
    services.flatpak.update.onActivation = true;
    services.flatpak.uninstallUnmanaged = true;
    services.flatpak.update.auto = {
      enable = true;
      onCalendar = "weekly";
    };

    services.flatpak.overrides = {
      global = {
        Environment = {
          # Fix un-themed cursor in some Wayland apps
          XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";
          # Force correct theme for some GTK apps
          GTK_THEME = "Adwaita:dark";
        };
      };
    };
  };
}
