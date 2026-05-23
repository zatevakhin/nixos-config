{self, ...}: {
  flake.nixosModules.lstr-configuration = {
    pkgs-unstable,
    hostname,
    username,
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      self.nixosModules.homeworld-certificate
      self.nixosModules.firewall-defaults
      self.nixosModules.openssh-defaults
      self.nixosModules.opentabletdriver
      self.nixosModules.binfmt-aarch64
      self.nixosModules.languagetool
      self.nixosModules.development
      self.nixosModules.nix-index
      self.nixosModules.desktop
      self.nixosModules.docker
      self.nixosModules.laptop
      self.nixosModules.nvidia
      self.nixosModules.nixvim
      self.nixosModules.tmux
      self.nixosModules.qemu
      self.nixosModules.adb
      self.nixosModules.tor
    ];

    # NOTE: Using this kernel because of issue with built in display.
    boot.kernelPackages = pkgs.linuxPackages_6_12;

    services.flatpak.packages = lib.mkIf config.services.flatpak.enable [
      "app.zen_browser.zen"
      "org.torproject.torbrowser-launcher"
      "io.github.tdesktop_x64.TDesktop"
      "md.obsidian.Obsidian"
      "org.signal.Signal"
      "chat.simplex.simplex"
      "com.obsproject.Studio"
      "app.grayjay.Grayjay"
      "org.onlyoffice.desktopeditors"
      "com.valvesoftware.SteamLink"
    ];

    # <sops>
    sops.defaultSopsFormat = "yaml";
    sops.defaultSopsFile = ../../secrets/${hostname}/default.yaml;
    sops.age.sshKeyPaths = [
      "/etc/ssh/ssh_host_ed25519_key"
      "/home/${username}/.ssh/id_ed25519"
    ];
    sops.secrets."user/password/hashed" = {};
    sops.secrets."user/password/hashed".neededForUsers = true;
    # </sops>

    # <docker>
    virtualisation.docker.storageDriver = "btrfs";
    hardware.nvidia-container-toolkit.enable = lib.mkForce true;
    # </docker>

    # <docker>
    nixpkgs.overlays = [
      (self: super: {devenv = pkgs-unstable.devenv;})
    ];
    # <docker>

    nixpkgs.config.allowUnfree = true;

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
        "wheel"
        "dialout"
      ];
    };

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.05"; # Did you read the comment?
  };
}
