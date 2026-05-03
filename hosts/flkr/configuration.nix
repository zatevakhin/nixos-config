{self, ...}: {
  flake.nixosModules.flkr-configuration = {
    hostname,
    username,
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      self.nixosModules.kernel-latest
      self.nixosModules.homeworld-certificate
      self.nixosModules.firewall-defaults
      self.nixosModules.openssh-defaults
      self.nixosModules.development
      self.nixosModules.desktop
      self.nixosModules.nvidia
      self.nixosModules.tmux
      self.nixosModules.qemu
    ];
    # NOTE: Using this kernel because latest does not support Nvidia 565.77 driver.
    # boot.kernelPackages = pkgs.linuxPackages_6_12;

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
    sops.secrets.ssh-authorized-key-lstr.key = "ssh/authorized/lstr";
    # </sops>

    # <gaming>
    # StarCitizen
    boot.kernel.sysctl = {
      "vm.max_map_count" = 1048576;
      "fs.file-max" = 524288;
    };
    # </gaming>

    # <docker>
    virtualisation.docker.storageDriver = "btrfs";
    hardware.nvidia-container-toolkit.enable = lib.mkForce true;
    # </docker>

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

    # <openssh>
    services.openssh.settings.X11Forwarding = lib.mkForce true;

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
    # </openssh>

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "24.05"; # Did you read the comment?
  };
}
