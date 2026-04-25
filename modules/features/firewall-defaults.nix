{...}: {
  flake.nixosModules.firewall-defaults = {
    pkgs,
    lib,
    ...
  }: {
    networking.firewall.enable = lib.mkDefault true;
  };
}
