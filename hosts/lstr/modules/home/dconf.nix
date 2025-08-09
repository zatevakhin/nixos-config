{...}: {
  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-options = "zoom";

      picture-uri = builtins.fetchurl {
        url = "https://images8.alphacoders.com/128/1285341.jpg";
        sha256 = "199ly8yyj8v72v6qvwp04zdhm51fcxb0qxli5lg2fr4zwiz2hm6f";
      };

      picture-uri-dark = builtins.fetchurl {
        url = "https://images8.alphacoders.com/128/1285341.jpg";
        sha256 = "199ly8yyj8v72v6qvwp04zdhm51fcxb0qxli5lg2fr4zwiz2hm6f";
      };
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = true;
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      clock-show-weekday = true;
      clock-format = "24h";
      icon-theme = "Papirus-Dark";
      enable-hot-corners = false;
      clock-show-seconds = true;
      accent-color = "blue";
    };

    "org/gnome/desktop/calendar" = {
      show-weekdate = true;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":minimize,maximize,close";
      # Activate windows on hover
      focus-mode = "sloppy";
    };

    "org/gnome/desktop/input-sources" = {
      per-window = true;
    };

    "org/gnome/desktop/sound" = {
      event-sounds = false;
    };

    "org/gnome/nautilus/icon-view" = {
      captions = ["size" "none" "none"];
    };

    "org/gnome/shell" = {
      last-selected-power-profile = "performance";

      favorite-apps = [
        "app.zen_browser.zen.desktop"
        "org.gnome.Nautilus.desktop"
        "io.github.tdesktop_x64.TDesktop.desktop"
      ];

      "keybindings/show-screenshot-ui" = [];
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };

    "org/gnome/settings-daemon/plugins/color" = {
      night-light-enabled = true;
      night-light-temperature = 2700;
      # TODO: Time of year/Location dependent
      night-light-schedule-from = 21.0;
      night-light-schedule-to = 7.0;
    };

    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
