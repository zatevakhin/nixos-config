{self, ...}: {
  flake.nixosModules.gnome = {
    username,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      self.nixosModules.gsconnect
      self.nixosModules.fonts
    ];

    # Enable the GNOME Desktop Environment.
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
    systemd.services."getty@tty1".enable = false;
    systemd.services."autovt@tty1".enable = false;

    # Enable automatic login for the user.
    services.displayManager.autoLogin.enable = true;
    services.displayManager.autoLogin.user = username;

    # Keyring
    services.gnome.gnome-keyring.enable = true;
    # PAM integration for keyring (critical)
    security.pam.services = {
      gdm.enableGnomeKeyring = true;
      gdm-password.enableGnomeKeyring = true;
      login.enableGnomeKeyring = true;
      gdm-autologin.enableGnomeKeyring = true;
    };

    environment.sessionVariables = {
      NIXOS_OZONE_WL = "1";
      QT_QPA_PLATFORM = "wayland";
      XCURSOR_SIZE = lib.mkForce "12"; # BUG: Cursor oversized on Xwayland applications
    };

    environment.variables = {
      XCURSOR_SIZE = lib.mkForce "12"; # BUG: Cursor oversized on Xwayland applications
    };

    # Thumbnailer service.
    services.tumbler.enable = true;

    # Enable touchpad support (enabled default in most desktopManager).
    services.libinput.enable = true;

    # Uniform look for Qt and GTK applications
    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita-dark";
    };

    # Override some internationalisation properties.
    i18n.defaultLocale = lib.mkForce "en_US.UTF-8";
    i18n.supportedLocales = lib.mkForce ["en_US.UTF-8/UTF-8" "ja_JP.UTF-8/UTF-8"];

    i18n.inputMethod = {
      enable = true;
      type = "ibus";
      ibus.engines = with pkgs.ibus-engines; [mozc anthy];
    };

    # Basic applications
    environment.systemPackages = with pkgs; [
      dconf-editor
      foliate

      # Theming
      papirus-icon-theme

      # Thumbnailer for videos
      ffmpegthumbnailer
    ];

    # Cleanup unused apps
    environment.gnome.excludePackages = with pkgs; [
      gnome-software
      gnome-system-monitor
      gnome-contacts
      gnome-music
      gnome-tour
      gnome-logs
      cheese
      gedit
      epiphany
      geary
      totem
      sound-theme-freedesktop
      gnome-text-editor
    ];
  };
}
