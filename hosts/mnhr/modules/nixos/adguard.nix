{...}: {
  services.adguardhome = {
    enable = true;
    mutableSettings = false;
    openFirewall = true;
    # NOTE: Access only trough reverse proxy.
    host = "127.0.0.1";
    port = 3000;
    settings = {
      # TODO: Configure auth.

      language = "en";
      theme = "auto";

      dns = {
        ratelimit = 300;
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
            domain = "lstr.lan";
            answer = "192.168.1.229";
          }
          {
            domain = "falke.lan";
            answer = "192.168.1.246";
          }
          {
            domain = "restreamer.homeworld.lan";
            answer = "mnhr.lan";
          }
          {
            domain = "research.homeworld.lan";
            answer = "mnhr.lan";
          }
          {
            domain = "grocy.homeworld.lan";
            answer = "mnhr.lan";
          }
          {
            domain = "kitchenowl.homeworld.lan";
            answer = "mnhr.lan";
          }
          {
            domain = "stump.homeworld.lan";
            answer = "mnhr.lan";
          }
          {
            domain = "radarr.homeworld.lan";
            answer = "mnhr.lan";
          }
          {
            domain = "sonarr.homeworld.lan";
            answer = "mnhr.lan";
          }
          {
            domain = "bazarr.homeworld.lan";
            answer = "mnhr.lan";
          }
          {
            domain = "sabnzbd.homeworld.lan";
            answer = "mnhr.lan";
          }
        ];
      };
    };
  };
}
