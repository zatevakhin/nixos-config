{
  pkgs,
  config,
  hostname,
  ...
}: let
  domain = "homeworld.lan";
  radarr_domain = "radarr.${domain}";
  sonarr_domain = "sonarr.${domain}";
  bazarr_domain = "bazarr.${domain}";
  lidarr_domain = "lidarr.${domain}";
  readarr_domain = "readarr.${domain}";
  prowlarr_domain = "prowlarr.${domain}";
  jellyseerr_domain = "jellyseerr.${domain}";
  qbittorrent_domain = "qbittorrent.${domain}";
in {
  services.adguardhome.settings.filtering.rewrites = [
    {
      domain = "${radarr_domain}";
      answer = "${hostname}.lan";
    }
    {
      domain = "${sonarr_domain}";
      answer = "${hostname}.lan";
    }
    {
      domain = "${bazarr_domain}";
      answer = "${hostname}.lan";
    }
    {
      domain = "${lidarr_domain}";
      answer = "${hostname}.lan";
    }
    {
      domain = "${readarr_domain}";
      answer = "${hostname}.lan";
    }
    {
      domain = "${prowlarr_domain}";
      answer = "${hostname}.lan";
    }
    {
      domain = "${jellyseerr_domain}";
      answer = "${hostname}.lan";
    }
    {
      domain = "${qbittorrent_domain}";
      answer = "${hostname}.lan";
    }
  ];

  sops.secrets.proton-vpn-private-key = {
    sopsFile = ../../secrets/proton-vpn.yaml;
    format = "yaml";
    key = "private-key";
  };

  systemd.services.arr-stack-compose = {
    environment = {
      PROTON_VPN_PRIVATE_KEY_PATH = config.sops.secrets.proton-vpn-private-key.path;
      RADARR_DOMAIN_NAME = radarr_domain;
      SONARR_DOMAIN_NAME = sonarr_domain;
      BAZARR_DOMAIN_NAME = bazarr_domain;
      LIDARR_DOMAIN_NAME = lidarr_domain;
      READARR_DOMAIN_NAME = readarr_domain;
      PROWLARR_DOMAIN_NAME = prowlarr_domain;
      JELLYSEERR_DOMAIN_NAME = jellyseerr_domain;
      QBITTORRENT_DOMAIN_NAME = qbittorrent_domain;
    };

    script = "${pkgs.docker-compose}/bin/docker-compose -f ${./docker-compose.yml} up";

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "traefik.service"];
  };
}
