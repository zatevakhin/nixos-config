{...}: {
  flake.nixosModules.firewall-defaults = {lib, ...}: {
    # WARN: Firewall rules may be overwritten by Docker, as per https://github.com/NixOS/nixpkgs/issues/111852
    # source: https://nixos.wiki/wiki/Firewall

    networking.firewall.enable = lib.mkDefault true;
    networking.nftables.enable = lib.mkDefault true;
  };
}
