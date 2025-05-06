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
    ../../modules/nixos/docker.nix
    ../../modules/nixos/openssh.nix
    # Machine specific modules
    ./modules/nixos/syncthing.nix
    # <containers>
    ./containers/traefik
    ./containers/calibre-web
    ./containers/paperless-ngx
    # </containers>
  ];

  # <sops>
  sops.defaultSopsFormat = "yaml";
  sops.defaultSopsFile = ./secrets/default.yaml;
  sops.age.sshKeyPaths = ["/etc/ssh/ssh_host_ed25519_key"];

  sops.secrets.user-password-hashed.key = "user/password/hashed";
  sops.secrets.ssh-authorized-key-baseship.key = "ssh/authorized/baseship";
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

  # <kernel>
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
  # </kernel>

  # <networking>
  networking.hostName = hostname;
  # </networking>

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Users are immutable and managed by NixOS
  users.mutableUsers = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.${username} = {
    useDefaultShell = true;
    hashedPasswordFile = config.sops.secrets.user-password-hashed.path;
    isNormalUser = true;
    description = "Ivan Zatevakhin";
    extraGroups = ["wheel"];
  };

  # HACK: What and Why? Because I can't do something like this with sops-nix.
  # ```nix
  # users.users.root.openssh.authorizedKeys.keyFiles = [
  #   sops.secrets.ssh-authorized-key-<key-name>.path
  # ];
  # ```
  # <hack>
  services.openssh.authorizedKeysInHomedir = lib.mkForce false;

  sops.templates."ssh-authorized-keys-for-${username}" = {
    content = ''
      ${config.sops.placeholder.ssh-authorized-key-baseship}
    '';
    owner = username; # NOTE: or ${username} will not be able to enter trough ssh.
  };

  environment.etc."ssh-authorized-keys-for-${username}" = {
    target = "ssh/authorized_keys.d/${username}";
    source = config.sops.templates."ssh-authorized-keys-for-${username}".path;
  };

  sops.templates."ssh-authorized-keys-for-${config.users.users.root.name}".content = ''
    ${config.sops.placeholder.ssh-authorized-key-baseship}
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
  system.stateVersion = "24.05"; # Did you read the comment?
}
