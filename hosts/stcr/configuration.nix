{
  config,
  pkgs,
  lib,
  username,
  hostname,
  ...
}: {
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
    # Shared modules
    ../../modules/nixos/base.nix
    ../../modules/nixos/zsh-mini.nix
    ../../modules/nixos/openssh.nix
    ../../modules/nixos/tor.nix
  ];

  # <sops>
  sops.defaultSopsFormat = "yaml";
  sops.defaultSopsFile = ./secrets/default.yaml;
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];
  # <ssh-key>
  # NOTE: Use only on build-vm
  # sops.age.sshKeyPaths = [../../extra-files/stcr/etc/ssh/ssh_host_ed25519_key];
  # environment.etc."/etc/ssh/ssh_host_ed25519_key" = {
  #   source = ../../extra-files/stcr/etc/ssh/ssh_host_ed25519_key;
  #   mode = "0600";
  #   user = "root";
  #   group = "root";
  # };
  # environment.etc."/etc/ssh/ssh_host_ed25519_key.pub" = {
  #   source = ../../extra-files/stcr/etc/ssh/ssh_host_ed25519_key.pub;
  #   mode = "0600";
  #   user = "root";
  #   group = "root";
  # };

  # </ssh-key>

  sops.secrets.user-password-hashed.key = "user/password/hashed";
  sops.secrets.ssh-authorized-key-lstr.key = "ssh/authorized/lstr";
  # </sops>

  # <kernel>
  boot.kernelPackages = pkgs.linuxPackages_latest;
  # </kernel>

  # <networking>
  networking.hostName = hostname;
  networking.firewall.enable = lib.mkForce false;
  # </networking>

  # Set your time zone.
  time.timeZone = "Europe/Kyiv";

  # Users are immutable and managed by NixOS
  users.mutableUsers = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    useDefaultShell = true;
    initialPassword = "admin";
    #hashedPasswordFile = config.sops.secrets.user-password-hashed.path;
    isNormalUser = true;
    description = "Ivan Zatevakhin";
    extraGroups = ["wheel"];
  };

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
      secretKey = ./hs_ed25519_secret_key;
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

  # HACK: What and Why? Because I can't do something like this with sops-nix.
  # ```nix
  # users.users.root.openssh.authorizedKeys.keyFiles = [
  #   sops.secrets.ssh-authorized-key-lstr.path
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
}
