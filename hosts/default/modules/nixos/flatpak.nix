{...}: {
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
    "in.cinny.Cinny"
    "io.github.gamingdoom.Datcord"
    "com.github.tchx84.Flatseal"
    "io.github.zen_browser.zen"
    "net.werwolv.ImHex"
    "fr.romainvigier.MetadataCleaner"
    "com.github.jeromerobert.pdfarranger"
    "com.tomjwatson.Emote"
    "net.lutris.Lutris"
    "com.bambulab.BambuStudio"
  ];
}
