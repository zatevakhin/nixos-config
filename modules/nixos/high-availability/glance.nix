{
  lib,
  pkgs,
  config,
  hostname,
  ...
}: let
  dashboard-icons = pkgs.callPackage ../../packages/dashboard-icons {};
  GLANCE_HTTP_PORT = 8001;
  HIGH_AVAILABILITY_HOSTS = ["arar" "mnhr" "sapr"];
in {
  networking.firewall.allowedTCPPorts = [GLANCE_HTTP_PORT];
  services.glance = {
    enable = true;
    openFirewall = true;
    settings = {
      server = {
        port = GLANCE_HTTP_PORT;
        host = "0.0.0.0";
        assets-path = "${dashboard-icons}/share/dashboard-icons/";
      };
      pages = [
        {
          name = "Home";
          columns = [
            {
              size = "small";
              widgets = [
                {
                  type = "calendar";
                }
                {
                  type = "rss";
                  limit = 10;
                  collapse-after = 3;
                  cache = "3h";
                  feeds = [
                    {
                      url = "https://ciechanow.ski/atom.xml";
                    }
                    {
                      url = "https://www.joshwcomeau.com/rss.xml";
                      title = "Josh Comeau";
                    }
                    {
                      url = "https://samwho.dev/rss.xml";
                    }
                    {
                      url = "https://awesomekling.github.io/feed.xml";
                    }
                    {
                      url = "https://ishadeed.com/feed.xml";
                      title = "Ahmad Shadeed";
                    }
                  ];
                }
                {
                  type = "twitch-channels";
                  channels = [
                    "theprimeagen"
                    "zatevakhin"
                    "asahilina"
                    "f1nn5ter"
                    "teej_dv"
                    "thebath"
                    "theo"
                  ];
                }
              ];
            }
            {
              size = "full";
              widgets = [
                {
                  type = "search";
                  search-engine = "duckduckgo";
                  bangs = [
                    {
                      title = "YouTube";
                      shortcut = "!yt";
                      url = "https://www.youtube.com/results?search_query={QUERY}";
                    }
                  ];
                }
                {
                  type = "hacker-news";
                }
                {
                  type = "videos";
                  channels = [
                    "UCR-DXc1voovS8nhAvccRZhg" # Jeff Geerling
                    "UCv6J_jJa8GJqFwQNgNrMuww" # ServeTheHome
                    "UCOk-gHyjcWZNj3Br4oxwh0A" # Techno Tim
                  ];
                }
              ];
            }
            {
              size = "small";
              widgets = [
                {
                  type = "weather";
                  location = "Lisbon, Portugal";
                  hour-format = "24h";
                }
                {
                  type = "dns-stats";
                  service = "adguard";
                  url = "https://adguard.homeworld.lan";
                }
                {
                  type = "markets";
                  markets = [
                    {
                      symbol = "BTC-USD";
                      name = "Bitcoin";
                    }
                    {
                      symbol = "ETH-USD";
                      name = "Ethereum";
                    }
                    {
                      symbol = "SOL-USD";
                      name = "Solana";
                    }
                  ];
                }
                {
                  type = "releases";
                  show-source-icon = true;
                  repositories = [
                    "immich-app/immich"
                    "paperless-ngx/paperless-ngx"
                    "dani-garcia/vaultwarden"
                    "AdguardTeam/AdGuardHome"
                    "advplyr/audiobookshelf"
                    "glanceapp/glance"
                    "wg-easy/wg-easy"
                    "tprasadtp/protonvpn-docker"
                    "ollama/ollama"
                    "dockerhub:linuxserver/calibre-web"
                    "codeberg:Forgejo/forgejo"
                    "dockerhub:sissbruecker/linkding"
                    "dockerhub:jellyfin/jellyfin"
                    "dockerhub:qbittorrentofficial/qbittorrent-nox"
                  ];
                }
              ];
            }
          ];
        }
        {
          name = "Dashboard";
          columns = [
            {
              size = "full";
              widgets = [
                {
                  type = "split-column";
                  max-columns = 4;
                  widgets = [
                    {
                      type = "monitor";
                      cache = "1m";
                      title = "Traefik";
                      sites =
                        (lib.optional config.services.traefik.enable {
                          title = "Traefik (main@${lib.toUpper hostname})";
                          url = "https://${config.systemd.services.traefik.environment.TRAEFIK_DOMAIN}";
                          icon = "/assets/svg/traefik.svg";
                        })
                        ++ (map (host: {
                          title = "Traefik (${lib.toUpper host})";
                          url = "https://traefik-${host}.homeworld.lan";
                          icon = "/assets/svg/traefik.svg";
                        }) (lib.filter (h: h != hostname) HIGH_AVAILABILITY_HOSTS));
                    }
                    {
                      type = "monitor";
                      cache = "1m";
                      title = "AdGuard";
                      sites = lib.flatten [
                        (lib.optional config.services.adguardhome.enable {
                          title = "AdGuard (main@${lib.toUpper hostname})";
                          url = "https://adguard.homeworld.lan";
                          icon = "/assets/svg/adguard-home.svg";
                        })
                      ];
                    }
                    {
                      type = "monitor";
                      cache = "1m";
                      title = "Syncthing";
                      sites = [
                        {
                          title = "Syncthing (ARAR)";
                          url = "https://syncthing-arar.homeworld.lan";
                          icon = "/assets/svg/syncthing.svg";
                        }
                        {
                          title = "Syncthing (MNHR)";
                          url = "https://syncthing-mnhr.homeworld.lan";
                          icon = "/assets/svg/syncthing.svg";
                        }
                      ];
                    }
                    {
                      type = "monitor";
                      cache = "1m";
                      title = "Arr Stack";
                      sites = [
                        {
                          title = "Radarr";
                          url = "https://radarr.homeworld.lan";
                          icon = "/assets/svg/radarr.svg";
                        }
                        {
                          title = "Sonarr";
                          url = "https://sonarr.homeworld.lan";
                          icon = "/assets/svg/sonarr.svg";
                        }
                        {
                          title = "Bazarr";
                          url = "https://bazarr.homeworld.lan";
                          icon = "/assets/svg/bazarr.svg";
                        }
                        {
                          title = "Lidarr";
                          url = "https://lidarr.homeworld.lan";
                          icon = "/assets/svg/lidarr.svg";
                        }
                        {
                          title = "Readarr";
                          url = "https://readarr.homeworld.lan";
                          icon = "/assets/svg/readarr.svg";
                        }
                        {
                          title = "Prowlarr";
                          url = "https://prowlarr.homeworld.lan";
                          icon = "/assets/svg/prowlarr.svg";
                        }
                        {
                          title = "Jellyseerr";
                          url = "https://jellyseerr.homeworld.lan";
                          icon = "/assets/svg/jellyseerr.svg";
                        }
                        {
                          title = "qBittorrent";
                          url = "https://qbittorrent.homeworld.lan";
                          icon = "/assets/svg/qbittorrent.svg";
                        }
                      ];
                    }
                    {
                      type = "monitor";
                      cache = "1m";
                      title = "Productivity & Communication";
                      sites = [
                        {
                          title = "SearxNG";
                          url = "https://searxng.homeworld.lan";
                          icon = "/assets/svg/searxng.svg";
                        }
                        {
                          title = "Vaultwarden";
                          url = "https://vw.homeworld.lan";
                          icon = "/assets/svg/vaultwarden.svg";
                        }
                        {
                          title = "OpenWebUI";
                          url = "https://owu.homeworld.lan";
                          icon = "/assets/png/open-webui.png";
                        }
                        {
                          title = "Forgejo";
                          url = "https://forgejo.homeworld.lan";
                          icon = "/assets/svg/forgejo.svg";
                        }
                        {
                          title = "Linkding";
                          url = "https://linkding.homeworld.lan";
                          icon = "/assets/svg/linkding.svg";
                        }
                        {
                          title = "Cinny Web";
                          url = "https://cinny.homeworld.lan";
                          icon = "/assets/svg/cinny.svg";
                        }
                      ];
                    }
                    {
                      type = "monitor";
                      cache = "1m";
                      title = "Entertainment & Media";
                      sites = [
                        {
                          title = "Jellyfin";
                          url = "http://jellyfin.homeworld.lan";
                          icon = "/assets/svg/jellyfin.svg";
                        }
                        {
                          title = "Calibre Web";
                          url = "https://books.homeworld.lan";
                          icon = "/assets/svg/calibre-web.svg";
                        }
                        {
                          title = "Audiobookshelf";
                          url = "https://abs.homeworld.lan";
                          icon = "/assets/svg/audiobookshelf.svg";
                        }
                        {
                          title = "Stump";
                          url = "https://stump.homeworld.lan";
                          icon = "/assets/svg/stump.svg";
                        }
                        {
                          title = "Navidrome";
                          url = "https://navidrome.homeworld.lan";
                          icon = "/assets/svg/navidrome.svg";
                        }
                      ];
                    }
                    {
                      type = "monitor";
                      cache = "1m";
                      title = "Network & Infrastructure";
                      sites = [
                        {
                          title = "Home Assistant";
                          url = "https://pixelpond-3114538102.duckdns.org:8124";
                          icon = "/assets/svg/home-assistant-alt.svg";
                        }
                        {
                          title = "Wireguard UI";
                          url = "https://wg.homeworld.lan";
                          icon = "/assets/svg/wireguard.svg";
                        }
                        {
                          title = "NodeRed";
                          url = "https://nodered.homeworld.lan";
                          icon = "/assets/svg/node-red.svg";
                        }
                        {
                          title = "Grafana";
                          url = "https://grafana.homeworld.lan";
                          icon = "/assets/svg/grafana.svg";
                        }
                        {
                          title = "Influxdb";
                          url = "https://influxdb.homeworld.lan";
                          icon = "/assets/svg/influxdb.svg";
                        }
                        {
                          title = "MinIO";
                          url = "https://console-minio.homeworld.lan";
                          icon = "/assets/svg/minio-light.svg";
                        }
                        {
                          title = "Vodafone Router";
                          url = "http://router.lan";
                          icon = "si:vodafone";
                        }
                      ];
                    }
                  ];
                }
              ];
            }
          ];
        }
        {
          name = "Reddit (AI)";
          columns = [
            {
              size = "full";
              widgets = [
                {
                  type = "split-column";
                  max-columns = 4;
                  widgets = [
                    {
                      type = "reddit";
                      subreddit = "artificial";
                      collapse-after = 15;
                    }
                    {
                      type = "reddit";
                      subreddit = "ArtificialInteligence";
                      collapse-after = 15;
                    }
                    {
                      type = "reddit";
                      subreddit = "MachineLearning";
                      collapse-after = 15;
                    }
                    {
                      type = "reddit";
                      subreddit = "singularity";
                      collapse-after = 15;
                    }
                    {
                      type = "reddit";
                      subreddit = "Automate";
                      collapse-after = 15;
                    }
                  ];
                }
              ];
            }
          ];
        }
        {
          name = "Reddit (Linux)";
          columns = [
            {
              size = "full";
              widgets = [
                {
                  type = "split-column";
                  max-columns = 4;
                  widgets = [
                    {
                      type = "reddit";
                      subreddit = "selfhosted";
                      collapse-after = 15;
                    }
                    {
                      type = "reddit";
                      subreddit = "homelab";
                      collapse-after = 15;
                    }
                    {
                      type = "reddit";
                      subreddit = "linux";
                      collapse-after = 15;
                    }
                    {
                      type = "reddit";
                      subreddit = "sysadmin";
                      collapse-after = 15;
                    }
                  ];
                }
              ];
            }
          ];
        }
        {
          name = "Reddit (LLMs)";
          columns = [
            {
              size = "full";
              widgets = [
                {
                  type = "split-column";
                  max-columns = 4;
                  widgets = [
                    {
                      type = "reddit";
                      subreddit = "LocalLLaMA";
                      collapse-after = 15;
                    }
                    {
                      type = "reddit";
                      subreddit = "LocalLLM";
                      collapse-after = 15;
                    }
                    {
                      type = "reddit";
                      subreddit = "LLMDevs";
                      collapse-after = 15;
                    }
                    {
                      type = "reddit";
                      subreddit = "LLM";
                      collapse-after = 15;
                    }
                  ];
                }
              ];
            }
          ];
        }
      ];
    };
  };
}
