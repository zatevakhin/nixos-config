{lib, ...}: let
  wg = import ../../secrets/wg.nix;
in {
  #networking.search = lib.mkForce [];
  networking.networkmanager.dns = lib.mkForce "none";
  networking.useHostResolvConf = lib.mkForce false;
  networking.resolvconf.enable = lib.mkForce false;
  #services.resolved.enable = lib.mkForce false;

  services.unbound = {
    enable = true;
    checkconf = true;
    settings = {
      server = {
        verbosity = 2;
        # Basic configuration
        interface = ["127.0.0.1"];
        port = 53;
        do-ip4 = true;
        do-ip6 = false;
        do-udp = true;
        do-tcp = true;

        # Access control
        access-control = [
          "127.0.0.0/8 allow"
          "192.168.0.0/16 allow"
          "10.0.0.0/8 allow"
        ];

        # Performance settings
        num-threads = 4;
        msg-cache-size = "64m";
        rrset-cache-size = "128m";
        cache-min-ttl = 300;
        cache-max-ttl = 14400;

        # # DNS rebinding prevention
        # private-address = [
        #   "192.168.0.0/16"
        #   "172.16.0.0/12"
        #   "10.0.0.0/8"
        # ];

        # Network change handling
        do-not-query-localhost = "no";
        cache-max-negative-ttl = "60";

        # Optimization for VPN switching
        infra-cache-min-rtt = "50";
        infra-keep-probing = "yes";

        # Cache optimization
        prefetch = "yes";
        prefetch-key = "yes";
        minimal-responses = "yes";
        serve-expired = "yes";
        serve-expired-ttl = "3600";

        # Security settings
        hide-identity = "yes";
        hide-version = "yes";
      };
      # Forward zones configuration
      forward-zone =
        [
          {
            # Home network
            name = "homeworld.lan.";
            forward-addr = ["192.168.1.191"];
            forward-first = "yes";
          }
          {
            # Default forwarding
            name = ".";
            forward-addr = [
              "192.168.1.191" # Local DNS
              "9.9.9.10" # Quad9 fallback
            ];
            forward-first = "yes";
          }
        ]
        ++ (map (domain: {
            # Work domains
            name = domain;
            forward-addr = ["192.168.128.254"];
            forward-first = "yes";
          })
          wg.work.search);
    };
  };
}
