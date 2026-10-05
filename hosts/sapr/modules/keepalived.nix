{...}: {
  flake.nixosModules.sapr-keepalived = {
    username,
    pkgs,
    ...
  }: let
    interface = "enp1s0";
  in {
    # VRRP is IP protocol 112, not a port. services.keepalived.openFirewall
    # writes iptables extraCommands, which the nftables firewall rejects.
    networking.firewall.extraInputRules = ''
      iifname "${interface}" meta l4proto vrrp accept comment "keepalived"
    '';

    services.keepalived = {
      enable = true;
      vrrpInstances = {
        internal = {
          interface = interface;
          state = "BACKUP";
          virtualRouterId = 50;
          priority = 50;
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
