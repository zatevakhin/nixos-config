{self, ...}: {
  flake.nixosModules.klbr-configuration = {
    hostname,
    username,
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      self.nixosModules.homeworld-certificate
      self.nixosModules.openssh-defaults
      self.nixosModules.firewall-defaults
      self.nixosModules.kernel-latest
      self.nixosModules.development
      self.nixosModules.desktop
      self.nixosModules.docker
      self.nixosModules.tmux
      self.nixosModules.tor
    ];

    services.flatpak.packages = lib.mkIf config.services.flatpak.enable [
      "app.zen_browser.zen"
      "org.torproject.torbrowser-launcher"
      "io.github.tdesktop_x64.TDesktop"
      "md.obsidian.Obsidian"
      "org.signal.Signal"
      "chat.simplex.simplex"
      "com.obsproject.Studio"
      "io.github.woelper.Oculante"
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

    # <docker>
    virtualisation.docker.storageDriver = "btrfs";
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

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.11"; # Did you read the comment?
  };
}
