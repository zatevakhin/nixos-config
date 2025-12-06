{
  pkgs,
  config,
  ...
}: {
  system.fsPackages = [pkgs.bindfs];
  fileSystems = let
    mkRoSymBind = path: {
      device = path;
      fsType = "fuse.bindfs";
      options = ["ro" "resolve-symlinks" "x-gvfs-hide"];
    };
    aggregatedIcons = pkgs.buildEnv {
      name = "system-icons";
      paths = with pkgs; [
        #libsForQt5.breeze-qt5  # for plasma
        gnome-themes-extra
      ];
      pathsToLink = ["/share/icons"];
    };
    aggregatedFonts = pkgs.buildEnv {
      name = "system-fonts";
      paths = config.fonts.packages;
      pathsToLink = ["/share/fonts"];
    };
  in {
    "/usr/share/icons" = mkRoSymBind "${aggregatedIcons}/share/icons";
    "/usr/local/share/fonts" = mkRoSymBind "${aggregatedFonts}/share/fonts";
  };

  fonts = {
    fontDir.enable = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-color-emoji
      nerd-fonts.fira-code
      source-han-sans
      source-han-mono
      source-han-serif
      source-han-code-jp
      xorg.fontalias
      xorg.fontmiscmisc
      xorg.fontcursormisc
    ];
  };

  # NOTE: (06-12-2025): In NixOS 25.11, the system-fonts build fails because both font-misc-misc and font-cursor-misc install an identical conflicting fonts.dir file in /share/fonts/X11/misc/.
  nixpkgs.overlays = [
    (self: super: {
      xorg = super.xorg.overrideScope (xself: xsuper: {
        fontmiscmisc = xsuper.fontmiscmisc.overrideAttrs (old: {
          postInstall =
            (old.postInstall or "")
            + ''
              rm -f $out/share/fonts/X11/misc/fonts.dir
            '';
        });
        fontcursormisc = xsuper.fontcursormisc.overrideAttrs (old: {
          postInstall =
            (old.postInstall or "")
            + ''
              rm -f $out/share/fonts/X11/misc/fonts.dir
            '';
        });
      });
    })
  ];
}
