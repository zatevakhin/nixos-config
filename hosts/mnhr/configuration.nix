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
    # Shared modules
    ../../modules/certs/root.nix
    ../../modules/nixos/base.nix
    ../../modules/nixos/zsh-mini.nix
    ../../modules/nixos/openssh.nix
    ../../modules/nixos/docker.nix
    # Machine specific modules
    ./modules/nixos/homepage.nix
    ./modules/nixos/step-ca.nix
    ./modules/nixos/step-ca-bootstrap.nix
    ./modules/nixos/step-certificates.nix
    # Containers
    ./containers/traefik
    ./containers/adguard
    # ISSUE: No hardware acceleration for video decoding in mainline ffmpeg.
    #        - https://github.com/edk2-porting/edk2-rk3588/issues/142#issuecomment-2426288640
    #        - https://github.com/jellyfin/jellyfin-ffmpeg/issues/34
    # ./containers/jellyfin
    ./containers/immich
    ./containers/glance
  ];

  # <sops>
  sops.defaultSopsFormat = "yaml";
  sops.defaultSopsFile = ./secrets/default.yaml;
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  sops.secrets."user/password/hashed" = {};
  # </sops>

  # <step-ca>
  services.step-ca-bootstrap = {
    enable = true;
    ca-url = "https://ca.homeworld.lan:8443";
    fingerprint = "3e38469e23830961ad4b3908934db7824c9492559e3540f693738762bf1867d5";
  };

  sops.secrets.step-provisioner-password-file = {
    sopsFile = ./secrets/step-ca.yaml;
    format = "yaml";
    key = "step/password";
  };

  services.step-certificates = {
    enable = true;
    provisioner = "admin";
    provisioner-password-file = config.sops.secrets.step-provisioner-password-file.path;
    ca-url = "https://ca.homeworld.lan:8443";
    renewal-interval = "OnCalendar=*-*-*/30 00:00:00";  # Every 30 days at midnight
    certificates = {
      "homeworld-wildcard" = {
        domain = "*.homeworld.lan";
        cert-dir = "traefik/certs";
        notify-service = "traefik.service";
        validity-period = 2160; # 90 days validity
      };
    };
  };
  # </step-ca>

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

  # <docker>
  # NOTE: Can't use MergerFS as data-root for docker. Looks like some issues with OverlayFS and MergerFS combined.
  # virtualisation.docker.daemon.settings = {
  #   data-root = "/mnt/storage/.system/docker";
  # };
  # </docker>

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
