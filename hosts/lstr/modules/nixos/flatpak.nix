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
    "app.zen_browser.zen"
    "org.mozilla.firefox"
    "org.torproject.torbrowser-launcher"
    "io.github.tdesktop_x64.TDesktop"
    "in.cinny.Cinny"
    "md.obsidian.Obsidian"
    "org.signal.Signal"
    "com.github.tchx84.Flatseal"
    "net.werwolv.ImHex"
    "fr.romainvigier.MetadataCleaner"
    "com.github.jeromerobert.pdfarranger"
    "com.tomjwatson.Emote"
    "net.lutris.Lutris"
    "dev.bragefuglseth.Keypunch"
    "com.obsproject.Studio"
    "io.github.woelper.Oculante"
    "org.tenacityaudio.Tenacity"
    "net.minetest.Minetest"
    "com.github.taiko2k.tauonmb"
    "io.github.hakuneko.HakuNeko"
    "app.grayjay.Grayjay"
    "io.github.nozwock.Packet"
    "org.freecad.FreeCAD"
    "net.sapples.LiveCaptions"
    "dev.mariinkys.Oboete"
    "net.ankiweb.Anki"
    "org.onlyoffice.desktopeditors"
  ];

  networking.firewall.allowedTCPPorts = [
    9300 # Packet
  ];
}
