{
  config,
  pkgs,
  pkgs-unstable,
  inputs,
  lib,
  username,
  hostname,
  modulesPath,
  ...
}: let
  me = import ./secrets/user.nix;
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix

    # Shared modules
    ../../modules/nixos/base.nix
    ../../modules/nixos/openssh.nix
    # Machine specific modules
    ./modules/nixos/desktop.nix
    ./modules/nixos/development.nix
  ];

  # nix-collect-garbage
  # nix run 'github:nix-community/disko#disko-install' -- --flake .#raider --disk main /dev/vda
  # nix run nixpkgs#htop

  #<vm>
  services.qemuGuest.enable = true;
  #</vm>

  # <sops>
  sops.defaultSopsFormat = "yaml";
  sops.defaultSopsFile = ./secrets/default.yaml;
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key" "/home/${username}/.ssh/id_ed25519"];
  sops.secrets."user/password/hashed" = {};
  # </sops>

  nixpkgs.overlays = [
    # (self: super: {devenv = pkgs-unstable.devenv;})
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

  # NOTE: Using this kernel because still dependent on the Nvidia 535.179 driver.
  boot.kernelPackages = pkgs.linuxPackages_latest;

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
    extraGroups = ["networkmanager" "wheel" "docker"];
    packages = with pkgs; [
    ];
    openssh.authorizedKeys.keys = [
      me.ssh.authorized.baseship
    ];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    me.ssh.authorized.baseship
  ];

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

  environment.sessionVariables = {};

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
