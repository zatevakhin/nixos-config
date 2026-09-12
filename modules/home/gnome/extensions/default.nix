{...}: {
  flake.homeModules.gnome-extensions = {pkgs-unstable, ...}: {
    dconf.settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = with pkgs-unstable.gnomeExtensions; [
          blur-my-shell.extensionUuid
          appindicator.extensionUuid
          tiling-shell.extensionUuid
          # smart-home.extensionUuid
          gsconnect.extensionUuid
        ];
      };
    };

    home.packages = with pkgs-unstable.gnomeExtensions; [
      blur-my-shell
      appindicator
      tiling-shell
      # TODO: Add HomeAssistant configuration using `dconf`.
      # smart-home
      gsconnect
    ];
  };
}
