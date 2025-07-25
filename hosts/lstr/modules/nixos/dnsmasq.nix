{
  lib,
  config,
  ...
}: let
  wg = import ../../secrets/wg.nix;
in {
  services.resolved.enable = lib.mkIf (!config.services.dnsmasq.enable) true;

  specialisation = {
    laptop.configuration = {
      system.nixos.tags = ["laptop"];
      services.dnsmasq.enable = lib.mkForce false;
    };
  };

  services.dnsmasq = {
    enable = true;
    settings = {
      listen-address = "127.0.0.1";
      server =
        (map (domain: "/${domain}/192.168.128.254") wg.work.search)
        ++ [
          "/lan/192.168.1.191"
          "192.168.1.191"
          "9.9.9.10"
          "1.1.1.1"
          "1.0.0.1"
        ];
      no-resolv = true;
      no-poll = true;
      cache-size = 1000;

      dns-forward-max = 150;

      # Choose ONE of these behaviors:
      all-servers = false; # Query all at once
      # strict-order = false; # Force strict ordering
      # Default (neither): Try in order but skip known-bad servers

      # Detailed logging
      log-queries = false; # Log queries
      log-dhcp = false; # Log DHCP
      log-debug = false; # Enable debug logging
    };
  };
}
