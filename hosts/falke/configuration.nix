{
  config,
  pkgs,
  pkgs-unstable,
  inputs,
  lib,
  username,
  hostname,
  ...
}: let
  wg = import ./secrets/wg.nix;
  me = import ./secrets/user.nix;
in {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Shared modules
    ../../modules/nixos/base.nix
    #../../modules/nixos/nix-serve.nix
    ../../modules/nixos/openssh.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/qemu.nix
    ../../modules/nixos/logitech.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/firewall.nix
    ../../modules/nixos/nixvim.nix
    ../../modules/nixos/tmux.nix
    ../../modules/nixos/searxng.nix
    ../../modules/docker/ollama
    ../../modules/docker/comfyui
    # Machine specific modules
    ./modules/nixos/desktop.nix
    ./modules/nixos/development.nix
    ./modules/nixos/nvidia.nix
    ./modules/nixos/flatpak.nix
    # NOTE: Removed as new network card arrived.
    # ./modules/nixos/keepalived.nix
  ];

  # <sops>
  sops.defaultSopsFormat = "yaml";
  sops.defaultSopsFile = ./secrets/default.yaml;
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key" "/home/${username}/.ssh/id_ed25519"];
  sops.secrets."user/password/hashed" = {};
  sops.secrets."nix-cache/private_key" = {};
  # </sops>

  # <nix-serve>
  #services.nix-serve.secretKeyFile = config.sops.secrets."nix-cache/private_key".path;
  # </nix-serve>

  # <nixvim>
  programs.nixvim.plugins.avante.settings.providers.ollama.endpoint = lib.mkForce "http://localhost:11434";
  # </nixvim>

  # <docker>
  virtualisation.docker.storageDriver = "btrfs";
  hardware.nvidia-container-toolkit.enable = lib.mkForce true;
  # </docker>

  # <wireguard>
  networking.wg-quick.interfaces = {
    wg0 = {
      address = ["192.168.5.164/32"];
      dns = ["192.168.128.254"] ++ wg.work.search;
      autostart = false;
      listenPort = 51820;
      privateKey = wg.work.private_key;

      peers = [
        {
          publicKey = wg.work.public_key;
          allowedIPs = [
            "192.168.128.0/23"
            "192.168.150.0/24"
            "192.168.5.0/24"
            "192.168.151.0/24"
            "192.168.149.0/24" # HW and IGS
          ];
          endpoint = wg.work.endpoint;
          persistentKeepalive = 25;
        }
      ];
    };
  };
  # </wireguard>

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

  # NOTE: Using this kernel because latest does not support Nvidia 565.77 driver.
  boot.kernelPackages = pkgs.linuxPackages_6_12;

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
    packages = with pkgs; [];
    openssh.authorizedKeys.keys = [
      me.ssh.authorized.baseship
      me.ssh.authorized.eulr
    ];
  };

  # <openssh>
  services.openssh.settings.X11Forwarding = lib.mkForce true;
  users.users.root.openssh.authorizedKeys.keys = [
    me.ssh.authorized.baseship
  ];
  # </openssh>

  # <firewall>
  networking.firewall.allowedTCPPorts = [
    1880
    8081
  ];
  # </firewall>

  home-manager = {
    # also pass inputs to home-manager modules
    extraSpecialArgs = {inherit inputs username;};
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
