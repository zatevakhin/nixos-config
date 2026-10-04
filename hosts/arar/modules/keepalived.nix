{...}: {
  flake.nixosModules.arar-keepalived = {
    username,
    pkgs,
    ...
  }: let
    interface = "end0";
  in {
    # Inert while networking.firewall.enable is false. Required once that
    # is turned on, or arar stops hearing VRRP and the VIP splits.
    # services.keepalived.openFirewall is iptables-only and fails on nftables.
    networking.firewall.extraInputRules = ''
      iifname "${interface}" meta l4proto vrrp accept comment "keepalived"
    '';

    services.keepalived = {
      enable = true;
      vrrpInstances = {
        internal = {
          interface = interface;
          state = "MASTER";
          virtualRouterId = 50;
          priority = 100;
          virtualIps = [
            {
              addr = "192.168.1.100/32";
              dev = interface;
            }
          ];
        };
      };
    };
  };
}
