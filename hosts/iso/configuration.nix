{pkgs, ...}: let
  iso = import ./secrets/iso.nix;
in {
  environment.systemPackages = with pkgs; [
    nixos-install-tools
    fastfetch
    neovim
    parted
    sops
    htop
    git
  ];

  nix.settings.experimental-features = ["nix-command" "flakes"];
  systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];

  users.users.root.openssh.authorizedKeys.keys = [iso.ssh.authorized_keys.lstr];
  users.users.nixos = {
    openssh.authorizedKeys.keys = [iso.ssh.authorized_keys.lstr];
  };

  environment.etc."ssh-host-ed25519" = {
    source = ./secrets/ssh_host_ed25519_key;
    target = "ssh/ssh_host_ed25519_key";
  };
  environment.etc."ssh-host-ed25519-pub" = {
    source = ./secrets/ssh_host_ed25519_public_key.pub;
    target = "ssh/ssh_host_ed25519_key.pub";
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
  };

  services.tor = {
    enable = true;
    relay.onionServices = {
      ssh = {
        version = 3;
        secretKey = builtins.path {
          name = "ssh-service";
          path = ./secrets/hs_ed25519_secret_key;
        };

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
  };
}
