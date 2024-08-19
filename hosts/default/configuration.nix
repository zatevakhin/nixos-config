{
  config,
  pkgs,
  inputs,
  lib,
  username,
  hostname,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Separated modules
    ./modules/nixos/base.nix
    ./modules/nixos/desktop.nix
    ./modules/nixos/development.nix
    ./modules/nixos/gaming.nix
    ./modules/nixos/nvidia.nix
    ./modules/nixos/docker.nix
    ./modules/nixos/flatpak.nix
  ];

  sops.defaultSopsFormat = "yaml";
  sops.defaultSopsFile = ./secrets/default.yaml;
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key" "/home/${username}/.ssh/id_ed25519"];

  sops.secrets."user/password/hashed" = {};

  nixpkgs.overlays = [];

  networking.nftables.enable = false;
  networking.firewall.enable = false;

  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelPackages = pkgs.linuxPackages_6_6;

  networking.hostName = hostname; # Define your hostname.

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    useDefaultShell = true;
    hashedPasswordFile = config.sops.secrets."user/password/hashed".path;
    isNormalUser = true;
    description = "Ivan Zatevakhin";
    extraGroups = ["networkmanager" "wheel" "docker" "kvm" "libvirtd"];
    packages = with pkgs; [
    ];
  };

  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = {inherit inputs username;};
    users = {
      "${username}" = import ./home.nix;
    };
  };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
  ];

  nixpkgs.config.permittedInsecurePackages = [];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # services.gnome.gnome-keyring.enable = true;
  # programs.mtr.enable = true;
  # services.pcscd.enable = true;

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-gnome3;
  };

  environment.sessionVariables = {
  };

  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  hardware.bluetooth.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable sound with pipewire.
  sound.enable = true;

  hardware.pulseaudio.enable = false;

  security.rtkit.enable = true;

  services.pipewire = {
    enable = true;

    alsa.enable = true;
    alsa.support32Bit = true;

    pulse.enable = true;

    # If you want to use JACK applications, uncomment this
    jack.enable = true;
  };

  services.openssh = {
    enable = true;

    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # <desktop>
  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = username;

  qt = {
    enable = true;
    platformTheme = "gnome";
    style = "adwaita-dark";
  };
  # </desktop>

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
