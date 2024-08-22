{
  config,
  pkgs,
  pkgs-unstable,
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
    ../../modules/nixos/base.nix
    ./modules/nixos/desktop.nix
    ./modules/nixos/syncthing.nix
    ./modules/nixos/development.nix
    ./modules/nixos/gaming.nix
    ./modules/nixos/nvidia.nix
    ./modules/nixos/docker.nix
    ./modules/nixos/qemu.nix
    ./modules/nixos/flatpak.nix
  ];

  sops.defaultSopsFormat = "yaml";
  sops.defaultSopsFile = ./secrets/default.yaml;
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key" "/home/${username}/.ssh/id_ed25519"];

  sops.secrets."user/password/hashed" = {};

  nixpkgs.overlays = [
    (self: super: {devenv = pkgs-unstable.devenv;})
  ];

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

  services.openssh = {
    enable = true;

    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # Enable automatic login for the user.
  services.displayManager.autoLogin.enable = true;
  services.displayManager.autoLogin.user = username;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
