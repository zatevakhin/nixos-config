{
  pkgs,
  config,
  hostname,
  ...
}: let
  TRAEFIK_DOMAIN = "traefik.homeworld.lan";
  TRAEFIK_DOMAIN_HOST_SPECIFIC = "traefik-${hostname}.homeworld.lan";
  TRAEFIK_HTTP_PORT = 80;
  TRAEFIK_HTTPS_PORT = 443;
in {
  systemd.services.traefik = {
    serviceConfig = {
      SupplementaryGroups = ["docker"];
      StateDirectory = "traefik";
    };
    environment = {
      TRAEFIK_DOMAIN = TRAEFIK_DOMAIN;
      TRAEFIK_DOMAIN_HOST_SPECIFIC = TRAEFIK_DOMAIN_HOST_SPECIFIC;
      LEGO_CA_CERTIFICATES = pkgs.fetchurl {
        url = "https://step-ca.homeworld.lan:8443/roots.pem";
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
          address = ":${toString TRAEFIK_HTTP_PORT}";
          transport.respondingTimeouts = {
            readTimeout = "600s";
            idleTimeout = "600s";
            writeTimeout = "600s";
          };
        };

        websecure = {
          address = ":${toString TRAEFIK_HTTPS_PORT}";
          transport.respondingTimeouts = {
            readTimeout = "600s";
            idleTimeout = "600s";
            writeTimeout = "600s";
          };
        };
      };

      certificatesResolvers.stepca = {
        acme = {
          caServer = "https://step-ca.homeworld.lan:8443/acme/acme/directory";
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

          traefik-host-specific = {
            rule = "Host(`${config.systemd.services.traefik.environment.TRAEFIK_DOMAIN_HOST_SPECIFIC}`)";
            service = "dashboard@internal";
            entryPoints = ["websecure"];
            tls.certResolver = "stepca";
          };

          traefik-api-host-specific = {
            rule = "Host(`${config.systemd.services.traefik.environment.TRAEFIK_DOMAIN_HOST_SPECIFIC}`) && PathPrefix(`/api`)";
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

          step-ca = {
            rule = "Host(`step-ca.homeworld.lan`)";
            service = "step-ca";
            entryPoints = ["websecure"];
            tls.certResolver = "stepca";
          };

          glance = {
            rule = "Host(`glance.homeworld.lan`)";
            service = "glance";
            entryPoints = ["websecure"];
            tls.certResolver = "stepca";
          };

          syncthing = {
            rule = "Host(`syncthing-${hostname}.homeworld.lan`)";
            service = "syncthing";
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

        services.step-ca = {
          loadBalancer.servers = [
            {
              url = "http://localhost:${builtins.toString config.services.step-ca.port}";
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
        services.syncthing = {
          loadBalancer.servers = [
            {
              url = "http://localhost:8384";
            }
          ];
        };
      };
    };
  };

  networking.firewall.allowedTCPPorts = [TRAEFIK_HTTP_PORT TRAEFIK_HTTPS_PORT];
}
