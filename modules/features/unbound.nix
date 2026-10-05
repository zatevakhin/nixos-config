{...}: {
  flake.nixosModules.unbound = {
    config,
    lib,
    ...
  }: {
    networking.networkmanager.dns = lib.mkIf config.networking.networkmanager.enable "none";
    networking.nameservers = ["127.0.0.1"];

    services.unbound = {
      enable = true;
      checkconf = true;
      resolveLocalQueries = true;
      enableRootTrustAnchor = true;
      settings = {
        server = {
          verbosity = 1;
          interface = ["127.0.0.1"];
          port = 53;
          do-ip4 = true;
          do-ip6 = false;
          do-udp = true;
          do-tcp = true;
          access-control = [
            "127.0.0.0/8 allow"
          ];
          num-threads = 4;
          msg-cache-size = "64m";
          rrset-cache-size = "128m";
          cache-min-ttl = 300;
          cache-max-ttl = 14400;
          cache-max-negative-ttl = 60;
          do-not-query-localhost = false;
          infra-cache-min-rtt = 50;
          infra-keep-probing = true;
          prefetch = true;
          prefetch-key = true;
          minimal-responses = true;
          serve-expired = true;
          serve-expired-ttl = 3600;
          hide-identity = true;
          hide-version = true;
          tls-cert-bundle = "/etc/ssl/certs/ca-certificates.crt";
        };
        forward-zone = [
          {
            name = "homeworld.lan.";
            forward-addr = ["192.168.1.100"];
          }
          {
            name = ".";
            forward-addr = [
              "9.9.9.10@853#dns.quad9.net"
              "1.1.1.1@853#cloudflare-dns.com"
            ];
            forward-tls-upstream = true;
          }
        ];
      };
    };
  };
}
