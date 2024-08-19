{pkgs, ...}: {
  dconf.settings = {
    "org/gnome/desktop/background" = {
      picture-options = "zoom";

      picture-uri = builtins.fetchurl {
        url = "https://w.wallhaven.cc/full/ex/wallhaven-ex136k.jpg";
        sha256 = "00z10ykrh826vj0ch4vm62wbvy6q53jj752b2241cv62j4zxv56j";
      };

      picture-uri-dark = builtins.fetchurl {
        url = "https://w.wallhaven.cc/full/ex/wallhaven-ex136k.jpg";
        sha256 = "00z10ykrh826vj0ch4vm62wbvy6q53jj752b2241cv62j4zxv56j";
      };
    };

    "org/gnome/mutter" = {
      dynamic-workspaces = true;
    };

    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
      clock-show-weekday = true;
      clock-format = "24h";
      gtk-theme = "Adwaita";
      icon-theme = "Papirus-Dark";
      enable-hot-corners = false;
      clock-show-seconds = true;
    };

    "org/gnome/desktop/calendar" = {
      show-weekdate = true;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = ":minimize,maximize,close";
    };

    "org/gnome/desktop/input-sources" = {
      # xkb-options = ["grp:caps_toggle"];
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
      disable-user-extensions = false;
      enabled-extensions = [
        "appindicatorsupport@rgcjonas.gmail.com"
        "blur-my-shell@aunetx"
        "quake-mode@repsac-by.github.com"
        "tiling-assistant@leleat-on-github"
      ];

      favorite-apps = [
        "org.mozilla.firefox.desktop"
        "org.gnome.Nautilus.desktop"
        "code.desktop"
        "io.github.tdesktop_x64.TDesktop.desktop"
      ];

      "keybindings/show-screenshot-ui" = [];
    };

    "org/gnome/settings-daemon/plugins/power" = {
      sleep-inactive-ac-type = "nothing";
    };

    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
