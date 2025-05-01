{
  pkgs,
  config,
  ...
}: {
  systemd.services.traefik = {
    serviceConfig = {
      SupplementaryGroups = ["docker"];
      StateDirectory = "traefik";
    };
    environment = {
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
        insecure = true;
        dashboard = true;
      };

      global = {
        checkNewVersion = true;
        sendAnonymousUsage = false;
      };

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
          glance = {
            rule = "Host(`glance.homeworld.lan`)";
            service = "glance";
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
          grafana = {
            rule = "Host(`grafana.homeworld.lan`)";
            service = "grafana";
            entryPoints = ["websecure"];
            tls.certResolver = "stepca";
          };
          minio-api = {
            # ISSUE: Seems wildcard certificates was not created using force sync path on client side for now.
            rule = "HostRegexp(`{subdomain:[a-zA-Z0-9-]+}.minio.homeworld.lan`) || Host(`minio.homeworld.lan`)";
            service = "minio-api";
            entryPoints = ["websecure"];
            tls = {
              certResolver = "stepca";
              domains = [
                {
                  main = "minio.homeworld.lan";
                  sans = ["*.minio.homeworld.lan"];
                }
              ];
            };
          };
          minio-console = {
            rule = "Host(`console-minio.homeworld.lan`)";
            service = "console-minio";
            entryPoints = ["websecure"];
            tls = {
              certResolver = "stepca";
            };
          };
        };

        services.glance = {
          loadBalancer.servers = [
            {
              url = "http://localhost:${builtins.toString config.services.glance.settings.server.port}";
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
        services.grafana = {
          loadBalancer.servers = [
            {
              url = "http://localhost:3000";
            }
          ];
        };
        services.console-minio = {
          loadBalancer.servers = [
            {
              url = "http://localhost:9001";
            }
          ];
        };
        services.minio-api = {
          loadBalancer.servers = [
            {
              url = "http://localhost:9000";
            }
          ];
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];
}
