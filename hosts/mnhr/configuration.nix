{
  config,
  pkgs,
  lib,
  username,
  hostname,
  ...
}: let
  ssh = import ./secrets/ssh.nix;
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./modules/nixos/homepage.nix

    # Shared modules
    ../../modules/nixos/base.nix
    ../../modules/nixos/openssh.nix
    # Machine specific modules
  ];

  # <sops>
  sops.defaultSopsFormat = "yaml";
  sops.defaultSopsFile = ./secrets/default.yaml;
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  sops.secrets."user/password/hashed" = {};
  # </sops>

  nixpkgs.overlays = [
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
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = [ssh.authorized.baseship];
  };

  users.users.root.openssh.authorizedKeys.keys = [ssh.authorized.baseship];

  # <openssh>
  services.openssh.settings.PasswordAuthentication = lib.mkForce true;
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
  # </openssh>

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [];

  nixpkgs.config.permittedInsecurePackages = [];

  environment.sessionVariables = {};

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?
}
