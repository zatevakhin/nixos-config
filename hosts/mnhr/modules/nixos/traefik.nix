{
  pkgs,
  config,
  lib,
  ...
}: {
  systemd.services.traefik = {
    serviceConfig = {
      SupplementaryGroups = ["docker"];
      StateDirectory = "traefik";
    };
    environment = {
      TRAEFIK_DOMAIN = "tf.homeworld.lan";
      LEGO_CA_CERTIFICATES = pkgs.fetchurl {
        url = "https://ca.homeworld.lan:8443/roots.pem";
        hash = "sha256-+EsQqEb+jaLKq4/TOUTEwF/9lwU5mETu4MY4GTN1V+A=";
        curlOpts = "--insecure";
      };
    };
  };

  services.traefik = {
    enable = true;

    staticConfigOptions = {
      api = {
        insecure = false;
        dashboard = true;
      };

      global = {
        checkNewVersion = true;
        sendAnonymousUsage = false;
      };

      accessLog = {};

      providers = {
        docker = {
          exposedByDefault = false;
          endpoint = "unix:///var/run/docker.sock";
        };
      };

      entryPoints = {
        web = {
          address = ":80";
          transport.respondingTimeouts = {
            readTimeout = "600s";
            idleTimeout = "600s";
            writeTimeout = "600s";
          };
        };

        websecure = {
          address = ":443";
          transport.respondingTimeouts = {
            readTimeout = "600s";
            idleTimeout = "600s";
            writeTimeout = "600s";
          };
        };
      };

      certificatesResolvers.stepca = {
        acme = {
          caServer = "https://ca.homeworld.lan:8443/acme/acme/directory";
          certificatesDuration = 24;
          keyType = "EC256";
          storage = "/var/lib/traefik/acme.json";
          httpChallenge.entryPoint = "web";
        };
      };
    };

    dynamicConfigOptions = {
      http = {
        routers = {
          traefik = {
            rule = "Host(`${config.systemd.services.traefik.environment.TRAEFIK_DOMAIN}`)";
            service = "dashboard@internal";
            entryPoints = ["websecure"];
            tls.certResolver = "stepca";
          };

          traefik-api = {
            rule = "Host(`${config.systemd.services.traefik.environment.TRAEFIK_DOMAIN}`) && PathPrefix(`/api`)";
            service = "api@internal";
            entryPoints = ["websecure"];
            tls.certResolver = "stepca";
          };

          adguard = {
            rule = "Host(`adguard.homeworld.lan`)";
            service = "adguard";
            entryPoints = ["websecure"];
            tls.certResolver = "stepca";
          };

          glance = {
            rule = "Host(`glance.homeworld.lan`)";
            service = "glance";
            entryPoints = ["websecure"];
            tls.certResolver = "stepca";
          };

          jellyseerr = {
            rule = "Host(`jellyseerr.homeworld.lan`)";
            service = "jellyseerr";
            entryPoints = ["websecure"];
            tls.certResolver = "stepca";
          };

          # HACK: Until OpenWebUI don't support self signed certificates for ollama URL.
          ollama-http = {
            rule = "Host(`ollama.homeworld.lan`)";
            entryPoints = ["web"];
            service = "ollama";
          };
          ollama = {
            rule = "Host(`ollama.homeworld.lan`)";
            service = "ollama";
            entryPoints = ["websecure"];
            tls.certResolver = "stepca";
          };
          comfyui = {
            rule = "Host(`comfyui.homeworld.lan`)";
            service = "comfyui";
            entryPoints = ["websecure"];
            tls.certResolver = "stepca";
          };
          grafana = {
            rule = "Host(`${config.services.grafana.settings.server.domain}`)";
            service = "grafana";
            entryPoints = ["websecure"];
            tls.certResolver = "stepca";
          };
          minio-api = {
            rule = "Host(`${config.systemd.services.minio.environment.MINIO_DOMAIN}`)";
            service = "minio-api";
            entryPoints = ["websecure"];
            tls.certResolver = "stepca";
          };
          minio-console = {
            rule = "Host(`console-${config.systemd.services.minio.environment.MINIO_DOMAIN}`)";
            service = "console-minio";
            entryPoints = ["websecure"];
            tls.certResolver = "stepca";
          };
        };

        services.adguard = {
          loadBalancer.servers = [
            {
              url = "http://localhost:${builtins.toString config.services.adguardhome.port}";
            }
          ];
        };

        services.glance = {
          loadBalancer.servers = [
            {
              url = "http://localhost:${builtins.toString config.services.glance.settings.server.port}";
            }
          ];
        };

        services.jellyseerr = {
          loadBalancer.servers = [
            {
              url = "http://localhost:${builtins.toString config.services.jellyseerr.port}";
            }
          ];
        };

        services.ollama = {
          loadBalancer.servers = [
            {
              url = "http://falke.lan:11434";
            }
          ];
        };
        services.comfyui = {
          loadBalancer.servers = [
            {
              url = "http://falke.lan:8188";
            }
          ];
        };
        services.grafana = {
          loadBalancer.servers = [
            {
              url = "http://localhost:${builtins.toString config.services.grafana.settings.server.http_port}";
            }
          ];
        };
        services.console-minio = {
          loadBalancer.servers = [
            (let
              port = builtins.elemAt (lib.strings.splitString ":" config.services.minio.consoleAddress) 1;
            in {
              url = "http://localhost:${port}";
            })
          ];
        };
        services.minio-api = {
          loadBalancer.servers = [
            (let
              port = builtins.elemAt (lib.strings.splitString ":" config.services.minio.listenAddress) 1;
            in {
              url = "http://localhost:${port}";
            })
          ];
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
