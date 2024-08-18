{
  pkgs,
  lib,
  config,
  ...
}: {
  services.flatpak.enable = true;
  services.flatpak.update.onActivation = true;
  services.flatpak.update.auto = {
    enable = true;
    onCalendar = "weekly";
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
  ];
}
