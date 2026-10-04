{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.iso-configuration = {
    pkgs,
    lib,
    ...
  }: let
    nonsecrets = lib.importTOML "${inputs.notsecrets}/default.toml";
    authorizedKeys = with nonsecrets.authorized_keys; [klbr ntgh];
  in {
    imports = [self.nixosModules.openssh-defaults];

    nixpkgs.hostPlatform = "x86_64-linux";
    networking.hostName = "homeworld-installer";
    nix.settings.experimental-features = ["nix-command" "flakes"];

    environment.systemPackages = with pkgs; [
      nixos-install-tools
      fastfetch
      neovim
      parted
      sops
      htop
      git
    ];

    # The live image allows console access, but SSH is public-key only.
    services.openssh.settings = {
      PermitRootLogin = lib.mkForce "prohibit-password";
      PasswordAuthentication = lib.mkForce false;
      KbdInteractiveAuthentication = lib.mkForce false;
    };
    users.users.root.openssh.authorizedKeys.keys = authorizedKeys;
    users.users.nixos.openssh.authorizedKeys.keys = authorizedKeys;

    # Fixed installer identity, decrypted by git-agecrypt before building.
    environment.etc."ssh/ssh_host_ed25519_key" = {
      source = ../../secrets/iso/ssh_host_ed25519_key;
      mode = "0600";
    };
    environment.etc."ssh/ssh_host_ed25519_key.pub".source = ../../secrets/iso/ssh_host_ed25519_public_key.pub;
    services.openssh.hostKeys = lib.mkForce [
      {
        path = "/etc/ssh/ssh_host_ed25519_key";
        type = "ed25519";
      }
    ];

    services.tor = {
      enable = true;
      relay.onionServices.ssh = {
        version = 3;
        secretKey = ../../secrets/iso/hs_ed25519_secret_key;
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

    system.stateVersion = "26.05";
  };
}
