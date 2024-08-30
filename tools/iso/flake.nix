{
  description = "NixOS - Make Installation medium";
  inputs.nixos.url = "nixpkgs/24.05";
  outputs = {
    nixpkgs,
    self,
    nixos,
  }: {
    # TODO: Add system
    # TODO: Add sdcards
    # TODO: Add VM Image
    # TODO: Make wireguard otional
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
    nixosConfigurations = {
      exampleIso = nixos.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          "${nixos}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
          ({pkgs, ...}: let
            sshPubKey = builtins.readFile "${builtins.getEnv "HOME"}/.ssh/id_ed25519.pub";
          in {
            environment.systemPackages = with pkgs; [neovim parted git nixos-install-tools sops];
            nix.settings.experimental-features = ["nix-command" "flakes"];
            systemd.services.sshd.wantedBy = pkgs.lib.mkForce ["multi-user.target"];
            users.users.root.openssh.authorizedKeys.keys = [
              sshPubKey
            ];

            networking.wg-quick.interfaces = {
              wg0 = {
                address = ["10.8.0.x/24"];
                dns = ["10.8.1.x"];
                autostart = true;
                listenPort = 51820;
                privateKey = "xxx";

                peers = [
                  {
                    publicKey = "xxx";
                    presharedKey = "xxx";
                    allowedIPs = ["10.8.0.0/24" "10.8.1.0/24"];
                    endpoint = "xxx.duckdns.org:51820";
                    persistentKeepalive = 25;
                  }
                ];
              };
            };
          })
        ];
      };
    };
  };
}
