{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ./fonts.nix
    ../../../../modules/nixos/xserver.nix
    ../../../../modules/nixos/opengl.nix
    ../../../../modules/nixos/audio.nix
    ../../../../modules/nixos/bluetooth.nix
  ];

  environment.systemPackages = with pkgs; [
    # Basic applications
    mpv
    youtube-music
    keepassxc
    obs-studio
    dconf-editor
    legcord

    # Theming
    papirus-icon-theme

    # Thumbnailer for videos
    ffmpegthumbnailer
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

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Override some internationalisation properties.
  i18n.defaultLocale = lib.mkForce "en_US.UTF-8";
  i18n.supportedLocales = lib.mkForce ["en_US.UTF-8/UTF-8" "ja_JP.UTF-8/UTF-8"];

  i18n.inputMethod = {
    enable = true;
    type = "ibus";
    ibus.engines = with pkgs.ibus-engines; [mozc];
  };

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

  # Uniform look for Qt and GTK applications
  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };
}
