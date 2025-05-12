{
  pkgs,
  config,
  hostname,
  ...
}: let
  domain = "qb.homeworld.lan";
in {
  services.adguardhome.settings.filtering.rewrites = [
    {
      domain = domain;
      answer = "${hostname}.lan";
    }
  ];

  # NOTE: Configuration dome through config file in config directory.
  # /config/qBittorrent/qBittorrent.conf

  sops.secrets.proton-vpn-private-key = {
    sopsFile = ../../secrets/proton-vpn.yaml;
    format = "yaml";
    key = "private-key";
  };

  systemd.services.qbittorrent-compose = {
    environment = {
      INTERNAL_DOMAIN_NAME = domain;
      PROTON_VPN_PRIVATE_KEY_PATH = config.sops.secrets.proton-vpn-private-key.path;
    };

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose --file ${./docker-compose.yml} up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose --file ${./docker-compose.yml} stop";
      StandardOutput = "syslog";
      Restart = "on-failure";
      RestartSec = 5;
      StartLimitIntervalSec = 60;
      StartLimitBurst = 3;
    };

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "traefik.service"];
  };
}
