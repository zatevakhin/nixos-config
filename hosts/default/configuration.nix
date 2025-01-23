{
  config,
  pkgs,
  pkgs-unstable,
  inputs,
  lib,
  username,
  hostname,
  ...
}:
{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Shared modules
    ../../modules/nixos/base.nix
    ../../modules/nixos/openssh.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/qemu.nix
    ../../modules/nixos/laptop.nix
    ../../modules/nixos/logitech.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/tor.nix
    ../../modules/nixos/adb.nix
    ../../modules/nixos/appimage.nix
    ../../modules/nixos/nixvim.nix
    # Machine specific modules
    ./modules/nixos/desktop.nix
    ./modules/nixos/syncthing.nix
    ./modules/nixos/development.nix
    ./modules/nixos/nvidia.nix
    ./modules/nixos/flatpak.nix
    # NOTE: See what broken in Wayland. https://gist.github.com/probonopd/9feb7c20257af5dd915e3a9f2d1f2277
    ./modules/nixos/wayland.nix
    ./modules/nixos/wiregurad.nix
  ];

  # <stylix>
  stylix = {
    enable = true;
    autoEnable = false;
    polarity = "dark";

    image = builtins.fetchurl {
      url = "https://images8.alphacoders.com/128/1285341.jpg";
      sha256 = "199ly8yyj8v72v6qvwp04zdhm51fcxb0qxli5lg2fr4zwiz2hm6f";
    };
    imageScalingMode = "fill";

    targets = {
      console.enable = true;
      gnome.enable = true;
      gtk.enable = true;
      nixos-icons.enable = true;
      plymouth.enable = true;
    };
  };

  # TODO: Add fonts
  # <stylix>

  # <sops>
  sops.defaultSopsFormat = "yaml";
  sops.defaultSopsFile = ./secrets/default.yaml;
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key" "/home/${username}/.ssh/id_ed25519"];
  sops.secrets."user/password/hashed" = {};
  sops.secrets."user/password/hashed".neededForUsers = true;
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

  # <docker>
  virtualisation.docker.storageDriver = "btrfs";

  # NOTE: Now when running containers that require GPUs
  #       use next syntax to add GPUs to container.
  #       $ docker run --rm -it --device=nvidia.com/gpu=all nvidia/cuda...
  hardware.nvidia-container-toolkit.enable = lib.mkForce true;
  # </docker>


  nixpkgs.overlays = [
    (self: super: {devenv = pkgs-unstable.devenv;})
    (self: super: {neovim = pkgs-unstable.neovim;})
    (self: super: {neovim-unwrapped = pkgs-unstable.neovim-unwrapped;})
    (self: super: {vimPlugins = pkgs-unstable.vimPlugins;})
  ];

  programs.nix-ld.libraries = with pkgs; [
    # Add any missing dynamic libraries for unpackaged programs
    # here, NOT in environment.systemPackages
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # NOTE: Using `aarch64` emulation to build packages for Raspberry PIs
  boot.binfmt.emulatedSystems = [
    "aarch64-linux"
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  # <networking>
  networking.hostName = hostname; # Define your hostname.

  networking.networkmanager.enable = true;

  #
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [
    8080
    2021 # Open for BambuStudio
  ];
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
    extraGroups = ["networkmanager" "wheel" "kvm" "libvirtd" "dialout"];
    packages = with pkgs; [
      atlauncher # yes! today we playing Minecraft!
    ];
    openssh.authorizedKeys.keys = [];
  };

  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = {inherit inputs username pkgs-unstable;};
    users = {
      "${username}" = import ./home.nix;
    };
  };

  # List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
    xorg.xhost # required for docker x11 passthrough
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
