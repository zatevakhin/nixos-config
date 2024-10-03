{pkgs, ...}: {
  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        appindicator.extensionUuid
        blur-my-shell.extensionUuid
        tiling-assistant.extensionUuid
      ];
    };
  };

  home.packages = with pkgs.gnomeExtensions; [
    appindicator
    blur-my-shell
    tiling-assistant
  ];
}
