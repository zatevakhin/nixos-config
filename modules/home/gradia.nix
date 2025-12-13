{pkgs, ...}: {
  home.packages = with pkgs; [gradia];

  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
      binding = "Print";
      command = "${pkgs.gradia}/bin/gradia --screenshot";
      name = "Gradia";
    };
  };
}
