{
  config,
  pkgs,
  inputs,
  lib,
  username,
  hostname,
  ...
}: let
  me = import ./secrets/user.nix;
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./modules/nixos/syncthing.nix

    ../../modules/nixos/base.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/openssh.nix
    ../../modules/nixos/step-ca-bootstrap.nix
    # <containers>
    ./containers/traefik
    ./containers/forgejo
    ./containers/linkding
    ./containers/qbittorrent
    ./containers/calibre-web
    ./containers/paperless-ngx
    ./containers/audiobookshelf
    # </containers>
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
    fingerprint = "295b225084a9a421b5c9190cd3347467bb722b72efb19052bb8dea895081e0db";
  };
  # </step-ca>

  networking.hostName = hostname;

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    useDefaultShell = true;
    hashedPasswordFile = config.sops.secrets."user/password/hashed".path;
    openssh.authorizedKeys.keys = [
      me.ssh.authorized.baseship
    ];
    isNormalUser = true;
    description = "Ivan Zatevakhin";
    extraGroups = ["wheel" "docker"];
    packages = with pkgs; [];
  };

  users.users.root.openssh.authorizedKeys.keys = [
    me.ssh.authorized.baseship
  ];

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
  ];

  # <openssh>
  services.openssh.settings.PermitRootLogin = lib.mkForce "yes";
  # </openssh>

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.05"; # Did you read the comment?
}
