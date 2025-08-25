{
  lib,
  pkgs,
  config,
  hostname,
  ...
}: let
  dashboard-icons = pkgs.callPackage ../../../../modules/packages/dashboard-icons {};
  domain = "glance.homeworld.lan";
in {
  sops.secrets.adguard-password = {
    sopsFile = ../../secrets/adguard.yaml;
    format = "yaml";
    key = "password";
  };

  sops.templates."adguard-creds.env".content = ''
    ADGUARD_PASSWORD=${config.sops.placeholder.adguard-password}
  '';

  systemd.services.glance.serviceConfig.EnvironmentFile = lib.mkForce config.sops.templates."adguard-creds.env".path;

  services.adguardhome.settings.filtering.rewrites = [
    {
      domain = domain;
      answer = "${hostname}.lan";
    }
  ];

  services.glance = {
    enable = true;
    openFirewall = true;
    settings = {
      server = {
        port = 8001;
        host = "127.0.0.1";
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
                    "thebath"
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
                {
                  type = "reddit";
                  subreddit = "selfhosted";
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
                  username = "admin";
                  password = "\${ADGUARD_PASSWORD}";
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
              ];
            }
          ];
        }
        {
          name = "Home Lab";
          columns = [
            {
              size = "small";
              widgets = [
                {
                  type = "monitor";
                  cache = "1m";
                  title = "Network & Infrastructure";
                  sites =
                    [
                      {
                        title = "Home Assistant";
                        url = "https://pixelpond-3114538102.duckdns.org:8124";
                        icon = "/assets/svg/home-assistant-alt.svg";
                      }
                      {
                        title = "AdGuard";
                        url = "https://adguard.homeworld.lan";
                        icon = "/assets/svg/adguard-home.svg";
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
                        url = "http://192.168.1.1";
                        icon = "si:vodafone";
                      }
                    ]
                    ++ lib.flatten [
                      (lib.optional config.services.traefik.enable {
                        title = "Traefik (main)";
                        url = "https://${config.systemd.services.traefik.environment.TRAEFIK_DOMAIN}";
                        icon = "/assets/svg/traefik.svg";
                      })
                    ];
                }
                {
                  type = "monitor";
                  cache = "1m";
                  title = "Entertainment & Media";
                  sites =
                    [
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
                    ]
                    ++ lib.flatten [
                      (lib.optional config.services.audiobookshelf-compose.enable {
                        title = "Audiobookshelf";
                        url = "https://${config.services.audiobookshelf-compose.domain}";
                        icon = "/assets/svg/audiobookshelf.svg";
                      })
                      (lib.optional config.services.stump-compose.enable {
                        title = "Stump";
                        url = "https://${config.services.stump-compose.domain}";
                        icon = "/assets/svg/stump.svg";
                      })
                    ];
                }
                {
                  type = "monitor";
                  cache = "1m";
                  title = "Storage & Documents";
                  sites = [
                    {
                      title = "Paperless NGX";
                      url = "https://paperless.homeworld.lan";
                      icon = "/assets/svg/paperless-ngx.svg";
                    }
                    {
                      title = "Syncthing";
                      url = "https://syncthing.homeworld.lan";
                      icon = "/assets/svg/syncthing.svg";
                    }
                    {
                      title = "Immich";
                      url = "https://immich.homeworld.lan";
                      icon = "/assets/svg/immich.svg";
                    }
                  ];
                }
                {
                  type = "monitor";
                  cache = "1m";
                  title = "Productivity & Communication";
                  sites =
                    [
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
                    ]
                    ++ lib.flatten [
                      (lib.optional config.services.open-webui-compose.enable {
                        title = "OpenWebUI";
                        url = "https://${config.services.open-webui-compose.domain}";
                        icon = "/assets/png/open-webui.png";
                      })
                      (lib.optional config.services.deep-research-compose.enable {
                        title = "DeepResearch";
                        url = "https://${config.services.deep-research-compose.domain}";
                        icon = "si:onnx";
                      })
                      (lib.optional config.services.forgejo-compose.enable {
                        title = "Forgejo";
                        url = "https://${config.services.forgejo-compose.domain}";
                        icon = "/assets/svg/forgejo.svg";
                      })
                      (lib.optional config.services.linkding-compose.enable {
                        title = "Linkding";
                        url = "https://${config.services.linkding-compose.domain}";
                        icon = "/assets/svg/linkding.svg";
                      })
                      (lib.optional config.services.cinny-compose.enable {
                        title = "Cinny Web";
                        url = "https://${config.services.cinny-compose.domain}";
                        icon = "/assets/svg/cinny.svg";
                      })
                      (lib.optional config.services.grocy-compose.enable {
                        title = "Grocy";
                        url = "https://${config.services.grocy-compose.domain}";
                        icon = "/assets/svg/grocy.svg";
                      })
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
              ];
            }
            {
              size = "small";
              widgets = [
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
      ];
    };
  };
}
