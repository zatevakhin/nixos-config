{
  username,
  hostname,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Shared modules
    ../../modules/nixos/base.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/openssh.nix
    ../../modules/nixos/zsh-mini.nix
    ../../modules/nixos/laptop.nix
    ../../modules/nixos/logitech.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/searxng.nix
    ../../modules/nixos/tmux.nix
    ../../modules/nixos/tor.nix
    ../../modules/nixos/adb.nix
    # Machine specific modules
    ./modules/nixos/desktop.nix
    ./modules/nixos/development.nix
    ./modules/nixos/flatpak.nix
    ./modules/nixos/wayland.nix
    # Home
    ./modules/home/configuration.nix
  ];

  # <sops>
  sops.defaultSopsFormat = "yaml";
  sops.defaultSopsFile = ./secrets/default.yaml;
  sops.age.sshKeyPaths = [
    "/etc/ssh/ssh_host_ed25519_key"
    "/home/${username}/.ssh/id_ed25519"
  ];
  sops.secrets."user/password/hashed" = {};
  sops.secrets."user/password/hashed".neededForUsers = true;
  sops.secrets.ssh-authorized-key-lstr.key = "ssh/authorized/lstr";
  # </sops>

  # <certificates>
  security.pki.certificateFiles = [
    (pkgs.fetchurl {
      url = "https://step-ca.homeworld.lan:8443/roots.pem";
      hash = "sha256-+EsQqEb+jaLKq4/TOUTEwF/9lwU5mETu4MY4GTN1V+A=";
      curlOpts = "--insecure";
    })
  ];
  # </certificates>

  # <docker>
  virtualisation.docker.storageDriver = "btrfs";
  # </docker>

  # NOTE: Using `aarch64` emulation to build packages for Raspberry PIs
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  # <kernel>
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # </kernel>

  # <networking>
  networking.hostName = hostname;
  networking.firewall.enable = lib.mkForce true;
  # </networking>

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Users are immutable and managed by NixOS
  users.mutableUsers = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    useDefaultShell = true;
    hashedPasswordFile = config.sops.secrets."user/password/hashed".path;
    isNormalUser = true;
    description = "Ivan Zatevakhin";
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
    ];
  };

  # HACK: What and Why? Because I can't do something like this with sops-nix.
  # ```nix
  # users.users.root.openssh.authorizedKeys.keyFiles = [
  #   sops.secrets.ssh-authorized-key-xxx.path
  # ];
  # ```
  # <hack>
  services.openssh.authorizedKeysInHomedir = lib.mkForce false;

  sops.templates."ssh-authorized-keys-for-${username}" = {
    content = ''
      ${config.sops.placeholder.ssh-authorized-key-lstr}
    '';
    owner = username; # NOTE: or ${username} will not be able to enter trough ssh.
  };

  environment.etc."ssh-authorized-keys-for-${username}" = {
    target = "ssh/authorized_keys.d/${username}";
    source = config.sops.templates."ssh-authorized-keys-for-${username}".path;
  };

  sops.templates."ssh-authorized-keys-for-${config.users.users.root.name}".content = ''
    ${config.sops.placeholder.ssh-authorized-key-lstr}
  '';

  environment.etc."ssh-authorized-keys-for-${config.users.users.root.name}" = {
    target = "ssh/authorized_keys.d/${config.users.users.root.name}";
    source = config.sops.templates."ssh-authorized-keys-for-${config.users.users.root.name}".path;
  };
  # </hack>

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
    pinentryPackage = pkgs.pinentry-gnome3;
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
  system.stateVersion = "25.11"; # Did you read the comment?
}
