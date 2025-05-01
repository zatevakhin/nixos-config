{
  config,
  pkgs,
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
    ../../modules/nixos/base.nix
    ../../modules/nixos/zsh-mini.nix
    ../../modules/nixos/openssh.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/tor.nix
    # Machine specific modules
    ./modules/nixos/adguard.nix
    ./modules/nixos/glance.nix
    ./modules/nixos/step-ca.nix
    ./modules/nixos/traefik.nix
    #./modules/nixos/grafana.nix
    ./modules/nixos/minio.nix
    # All services in docker containers
    ./containers
  ];

  # <sops>
  sops.defaultSopsFormat = "yaml";
  sops.defaultSopsFile = ./secrets/default.yaml;
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  sops.secrets."user/password/hashed" = {};
  # </sops>

  # <certificates>
  security.pki.certificateFiles = [
    (pkgs.fetchurl {
      url = "https://ca.homeworld.lan:8443/roots.pem";
      hash = "sha256-+EsQqEb+jaLKq4/TOUTEwF/9lwU5mETu4MY4GTN1V+A=";
      curlOpts = "--insecure";
    })
  ];
  # </certificates>

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

  boot.kernelPackages = pkgs.linuxPackages_6_13;
  networking.hostName = hostname; # Define your hostname.
  networking.hostId = "906df12d";

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

  # <ssh-over-tor>
  sops.secrets.secret_key = {
    sopsFile = ./secrets/tor.yaml;
    format = "yaml";
    key = "services/ssh/secret_key";
    owner = config.systemd.services.tor.serviceConfig.User;
  };

  services.tor.relay.onionServices = {
    ssh = {
      version = 3;
      secretKey = config.sops.secrets.secret_key.path;
      map = [
        {
          port = 22;
          target = {
            addr = "127.0.0.1";
            port = 22;
          };
        }
      ];
    };
  };
  # </ssh-over-tor>

  # <docker>
  # BUG: Pinned docker version because v27.5.1 is dies randomly.
  virtualisation.docker.package = pkgs.docker_26;
  # </docker>

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
  ];

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
