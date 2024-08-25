{
  pkgs,
  lib,
  config,
  ...
}: {
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

  services.flatpak.packages = [
    "org.mozilla.firefox"
    "com.brave.Browser"
    "io.github.tdesktop_x64.TDesktop"
    "com.slack.Slack"
    "md.obsidian.Obsidian"
    "org.signal.Signal"
    "im.riot.Riot"
    "io.github.gamingdoom.Datcord"
    # "dev.toastbits.spmp"
  ];
}
