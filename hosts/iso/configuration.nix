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

  users.users.root.openssh.authorizedKeys.keys = [iso.ssh.authorized_keys.baseship];
  users.users.nixos.openssh.authorizedKeys.keys = [iso.ssh.authorized_keys.baseship];

  networking.wg-quick.interfaces = {
    wg0 = {
      address = ["10.8.0.4/24"];
      dns = ["10.0.1.3"];
      autostart = true;
      listenPort = 51820;
      privateKey = iso.wireguard.keys.private;

      peers = [
        {
          publicKey = iso.wireguard.keys.public;
          presharedKey = iso.wireguard.keys.preshared;
          allowedIPs = ["0.0.0.0/0" "::/0"];
          endpoint = iso.wireguard.endpoint;
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
