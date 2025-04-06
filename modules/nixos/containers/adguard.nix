{lib, ...}: {
  # TODO: Make AdGuard DNS as HA service.
  networking = {
    nat = {
      enable = true;
      internalInterfaces = ["ve-+"];
      # NOTE: Should be configured per-instance.
      externalInterface = lib.mkDefault null;
      enableIPv6 = false;
    };

    firewall = {
      enable = true;
      allowedTCPPorts = [53 3000];
      allowedUDPPorts = [53];
    };
  };

  containers.adguard = {
    autoStart = true;
    ephemeral = true;
    privateNetwork = true;
    hostAddress = "10.0.0.1";
    localAddress = "10.0.0.2";

    forwardPorts = [
      {
        containerPort = 53;
        hostPort = 53;
        protocol = "tcp";
      }
      {
        containerPort = 53;
        hostPort = 53;
        protocol = "udp";
      }
      {
        containerPort = 3000;
        hostPort = 3000;
        protocol = "tcp";
      }
    ];

    config = {
      config,
      pkgs,
      lib,
      ...
    }: {
      services.adguardhome = {
        enable = true;
        mutableSettings = false;
        host = "0.0.0.0";
        port = 3000;
        settings = {
          # TODO: Configure auth.

          dns = {
            ratelimit = 200;
            port = 53;
            fallback_dns = [
              "1.1.1.1"
              "1.0.0.1"
              "8.8.8.8"
              "8.8.4.4"
            ];

            bootstrap_dns = [
              "9.9.9.10"
              "149.112.112.10"
              "2620:fe::10"
              "2620:fe::fe:10"
            ];
            upstream_mode = "load_balance";
            upstream_dns = [
              "https://dns.cloudflare.com/dns-query"
              "https://dns.google/dns-query"
              "9.9.9.10"
              "149.112.112.10"
              "2620:fe::10"
              "2620:fe::fe:10"
            ];
            enable_dnssec = true;
          };
          filters = [
            {
              enabled = true;
              url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
              name = "AdGuard DNS filter";
            }
            {
              enabled = true;
              url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
              name = "AdGuard Default Blocklist";
            }
            {
              enabled = true;
              url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_12.txt";
              name = "Dandelion Sprout's Anti-Malware List";
            }
            {
              enabled = true;
              url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_27.txt";
              name = "OISD Blocklist Big";
            }
            {
              enabled = true;
              url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_30.txt";
              name = "Phishing URL Blocklist (PhishTank and OpenPhish)";
            }
          ];
          filtering = {
            safe_search.enabled = false;
            blocking_mode = "default";
            # TODO: Need to define services files and IP mapping somewhere.
            rewrites = [
              {
                domain = "abs.homeworld.lan";
                answer = "archive.lan";
              }
              {
                domain = "adguard.homeworld.lan";
                answer = "mnhr.lan";
              }
              {
                domain = "books.homeworld.lan";
                answer = "archive.lan";
              }
              {
                domain = "pihole.homeworld.lan";
                answer = "nuke.lan";
              }
              {
                domain = "mnhr.lan";
                answer = "192.168.1.191";
              }
              {
                domain = "glance.homeworld.lan";
                answer = "mnhr.lan";
              }
              {
                domain = "forgejo.homeworld.lan";
                answer = "archive.lan";
              }
              {
                domain = "immich.homeworld.lan";
                answer = "mnhr.lan";
              }
              {
                domain = "jellyfin.homeworld.lan";
                answer = "nuke.lan";
              }
              {
                domain = "linkding.homeworld.lan";
                answer = "archive.lan";
              }
              {
                domain = "paperless.homeworld.lan";
                answer = "archive.lan";
              }
              {
                domain = "qb.homeworld.lan";
                answer = "archive.lan";
              }
              {
                domain = "syncthing.homeworld.lan";
                answer = "archive.lan";
              }
              {
                domain = "wg.homeworld.lan";
                answer = "mnhr.lan";
              }
              {
                domain = "archive.lan";
                answer = "192.168.1.224";
              }
              {
                domain = "nuke.lan";
                answer = "192.168.1.102";
              }
              {
                domain = "ca.homeworld.lan";
                answer = "mnhr.lan";
              }
              {
                domain = "eulr.lan";
                answer = "192.168.1.194";
              }
              {
                domain = "vw.homeworld.lan";
                answer = "mnhr.lan";
              }
              {
                domain = "va.homeworld.lan";
                answer = "mnhr.lan";
              }
              {
                domain = "searxng.homeworld.lan";
                answer = "mnhr.lan";
              }
              {
                domain = "falke.lan";
                answer = "192.168.1.246";
              }
              {
                domain = "ntfy.homeworld.lan";
                answer = "mnhr.lan";
              }
              {
                domain = "nodered.homeworld.lan";
                answer = "mnhr.lan";
              }
              {
                domain = "ollama.homeworld.lan";
                answer = "mnhr.lan";
              }
              {
                domain = "owu.homeworld.lan";
                answer = "mnhr.lan";
              }
              {
                domain = "grafana.homeworld.lan";
                answer = "mnhr.lan";
              }
              {
                domain = "influxdb.homeworld.lan";
                answer = "mnhr.lan";
              }
              {
                domain = "minio.homeworld.lan";
                answer = "mnhr.lan";
              }
              {
                domain = "console-minio.homeworld.lan";
                answer = "mnhr.lan";
              }
              {
                domain = "*.minio.homeworld.lan";
                answer = "minio.homeworld.lan";
              }
            ];
          };
        };
      };

      system.stateVersion = "24.11";

      networking = {
        useHostResolvConf = lib.mkForce false;
        firewall = {
          enable = true;
          allowedTCPPorts = [53 3000];
          allowedUDPPorts = [53];
        };
        useDHCP = false;
        interfaces.eth0 = {
          ipv4.addresses = [
            {
              address = "10.0.0.2";
              prefixLength = 24;
            }
          ];
        };
      };
    };
  };
}
