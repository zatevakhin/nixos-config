{...}: {
  # WARN: Firewall rules may be overwritten by Docker, as per https://github.com/NixOS/nixpkgs/issues/111852
  # source: https://nixos.wiki/wiki/Firewall

  networking.firewall.enable = true;
  networking.nftables.enable = true;
}
