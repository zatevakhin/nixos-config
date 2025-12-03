{...}: let
  ADGUARD_DNS_PORT = 53;
  HOME_DOMAIN = "homeworld.lan";
in {
  networking.firewall.allowedUDPPorts = [ADGUARD_DNS_PORT];

  # TODO: Limit or Move query log.
  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    openFirewall = true;
    host = "0.0.0.0";
    port = 3000;
    settings = {
      # TODO: Configure auth.

      language = "en";
      theme = "auto";

      dns = {
        ratelimit = 300;
        port = ADGUARD_DNS_PORT;
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
        fastest_timeout = "1s";
        upstream_dns = [
          "https://dns.cloudflare.com/dns-query"
          "https://dns.google/dns-query"
          "9.9.9.10"
          "149.112.112.10"
          "2620:fe::10"
          "2620:fe::fe:10"
        ];
        enable_dnssec = true;
        anonymize_client_ip = false;
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
        rewrites =
          [
            # <machines>
            {
              domain = "router.lan";
              answer = "192.168.1.1";
            }
            {
              domain = "aeon.lan"; # Floating IP for AdGuard, Traefik, Step-CA and Glance.
              answer = "192.168.1.100";
            }
            {
              domain = "mnhr.lan";
              answer = "192.168.1.10";
            }
            {
              domain = "sapr.lan";
              answer = "192.168.1.11";
            }
            {
              domain = "arar.lan";
              answer = "192.168.1.12";
            }
            {
              domain = "flkr.lan";
              answer = "192.168.1.105";
            }
            {
              domain = "lstr.lan";
              answer = "192.168.1.229";
            }
            # </machines>
          ]
          ++
          # Machine: AEON (Floating IP)
          (map (service: {
              domain = "${service}.${HOME_DOMAIN}";
              answer = "aeon.lan";
            }) [
              "adguard"
              "step-ca"
              "glance"
              "traefik"
            ])
          ++
          # Machine: MNHR
          (map (service: {
              domain = "${service}.${HOME_DOMAIN}";
              answer = "mnhr.lan";
            }) [
              "wg"
              "vw"
              "abs"
              "owu"
              "ntfy"
              "cinny"
              "ollama"
              "immich"
              "stump"
              "searxng"
              "comfyui"
              "forgejo"
              "nodered"
              "linkding"
              "syncthing-mnhr"
              "grafana"
              "influxdb"
              "forgejo"
              "minio"
              "console-minio"
              "traefik-mnhr"
              # *arr
              "radarr"
              "sonarr"
              "bazarr"
              "lidarr"
              "readarr"
              "prowlarr"
              "jellyseerr"
              "qbittorrent"
            ])
          ++
          # Machine: SAPR
          (map (service: {
              domain = "${service}.${HOME_DOMAIN}";
              answer = "sapr.lan";
            }) [
              "jellyfin"
              "traefik-sapr"
            ])
          ++
          # Machine: ARAR
          (map (service: {
              domain = "${service}.${HOME_DOMAIN}";
              answer = "arar.lan";
            }) [
              "books"
              "paperless"
              "syncthing-arar"
              "traefik-arar"
            ]);
      };
    };
  };
}
