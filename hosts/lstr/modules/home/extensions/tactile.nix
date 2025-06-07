{pkgs, ...}: {
  dconf.settings = {
    "org/gnome/shell" = {
      enabled-extensions = with pkgs.gnomeExtensions; [
        tactile.extensionUuid
      ];
    };

    "org/gnome/shell/extensions/tactile" = {
      # Tile appearance
      text-color = "rgba(202,56,56,0.5)";
      border-color = "rgba(202,56,56,0.15)";
      background-color = "rgba(0,0,0,0.0)";

      # Layout #1
      col-0 = 2;
      col-1 = 1;
      col-2 = 1;
      col-3 = 2;

      row-0 = 1;
      row-1 = 1;
      row-2 = 0;
    };
  };

  home.packages = with pkgs.gnomeExtensions; [
    tactile
  ];
}
