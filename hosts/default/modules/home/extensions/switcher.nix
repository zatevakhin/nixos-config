{pkgs, ...}: {
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = with pkgs.gnomeExtensions; [
        switcher.extensionUuid
      ];
    };

    "org/gnome/shell/extensions/switcher" = {
      font-size = 22;
      max-width-percentage = 30;
      workspace-indicator = true;
      fade-enable = true;
      on-active-display = true;
    };
  };

  home.packages = with pkgs.gnomeExtensions; [
    switcher
  ];
}
