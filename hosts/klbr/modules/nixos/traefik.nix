{pkgs, ...}: {
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
    };
  };

  networking.firewall.allowedTCPPorts = [80 443];
}

