{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./fonts.nix
  ];

  environment.systemPackages = with pkgs; [
    # Basic applications
    tilix
    youtube-music
    keepassxc
    obs-studio

    # Theming
    papirus-icon-theme
  ];

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Ensure that Wayland is disabled
  services.xserver.displayManager.gdm.wayland = false;

  # Workaround for GNOME autologin: https://github.com/NixOS/nixpkgs/issues/103746#issuecomment-945091229
  systemd.services."getty@tty1".enable = false;
  systemd.services."autovt@tty1".enable = false;

  # Thumbnailer service.
  services.tumbler.enable = true;

  # Override some internationalisation properties.
  i18n.defaultLocale = lib.mkForce "en_US.UTF-8";
  i18n.supportedLocales = lib.mkForce ["en_US.UTF-8/UTF-8" "ja_JP.UTF-8/UTF-8"];

  i18n.inputMethod = {
    enabled = "ibus";
    ibus.engines = with pkgs.ibus-engines; [mozc];
  };
}
