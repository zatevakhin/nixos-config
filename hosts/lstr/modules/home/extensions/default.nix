{pkgs, ...}: {
  imports = [
    ./tactile.nix
    ./switcher.nix
  ];

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      enabled-extensions = with pkgs.gnomeExtensions; [
        appindicator.extensionUuid
        blur-my-shell.extensionUuid
        smart-home.extensionUuid
      ];
    };
  };

  home.packages = with pkgs.gnomeExtensions; [
    appindicator
    blur-my-shell
    # TODO: Add HomeAssistant configuration using `dconf`.
    smart-home
  ];
}
