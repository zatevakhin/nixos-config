{self, ...}: {
  flake.nixosModules.stcr-configuration = {
    hostname,
    username,
    config,
    lib,
    ...
  }: {
    imports = [
      self.nixosModules.homeworld-certificate
      self.nixosModules.firewall-defaults
      self.nixosModules.openssh-defaults
      self.nixosModules.kernel-latest
      self.nixosModules.tmux
      self.nixosModules.tor
    ];

    # <sops>
    sops.defaultSopsFormat = "yaml";
    sops.defaultSopsFile = ../../secrets/${hostname}/default.yaml;
    sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
    sops.secrets."user/password/hashed" = {};
    sops.secrets.ssh-authorized-key-lstr.key = "ssh/authorized/lstr";
    # </sops>

    # <networking>
    networking.firewall.enable = true;
    networking.hostName = hostname;
    # </networking>

    # Disable TTY
    console.enable = false;

    nixpkgs.config.allowUnfree = true;

    time.timeZone = "Europe/Kyiv";

    # Users are immutable and managed by NixOS
    users.mutableUsers = false;

    # Define a user account. Don't forget to set a password with ‘passwd’.
    users.users.${username} = {
      useDefaultShell = true;
      initialPassword = "admin";
      #hashedPasswordFile = config.sops.secrets."user/password/hashed".path;
      isNormalUser = true;
      description = "Ivan Zatevakhin";
      extraGroups = [
        "wheel"
      ];
    };

    # <openssh>
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

    sops.secrets.secret_key = {
      sopsFile = ../../secrets/${hostname}/tor.yaml;
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
    # </openssh>

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "25.11"; # Did you read the comment?
  };
}
