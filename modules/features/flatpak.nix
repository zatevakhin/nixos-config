{...}: {
  flake.nixosModules.flatpak = {...}: {
    services.flatpak.enable = true;
    services.flatpak.update.onActivation = true;
    services.flatpak.uninstallUnmanaged = true;
    services.flatpak.update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
    services.flatpak.packages = [
      "org.freedesktop.Platform.Icontheme.Adwaita"
    ];

    services.flatpak.overrides = {
      global = {
        Environment = {
          # Fix un-themed cursor in some Wayland apps
          XCURSOR_PATH = "/run/host/user-share/icons:/run/host/share/icons";
        };

        Context.filesystems = [
          "xdg-data/icons:ro"
          "/run/current-system/sw/share/icons:ro"
        ];
      };
    };
  };
}
