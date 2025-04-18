{
  pkgs,
  config,
  ...
}: {
  # NOTE: Configuration dome through config file in config directory.
  # /config/qBittorrent/qBittorrent.conf

  sops.secrets.proton-vpn-private-key = {
    sopsFile = ../../secrets/proton-vpn.yaml;
    format = "yaml";
    key = "private-key";
  };

  systemd.services.qbittorrent-compose = {
    environment = {
      PROTON_VPN_PRIVATE_KEY_PATH = config.sops.secrets.proton-vpn-private-key.path;
    };

    script = "${pkgs.docker-compose}/bin/docker-compose -f ${./docker-compose.yml} up";

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "traefik.service" "adguard-compose.service"];
    requires = ["docker.service" "traefik.service" "adguard-compose.service"];
  };
}
