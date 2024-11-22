{
  pkgs,
  config,
  ...
}: {
  systemd.services.vaultwarden-compose = {
    serviceConfig = {
    };

    environment = {
      VAULTWARDEN_DOMAIN = "vw.homeworld.lan";
      VAULTWARDEN_DATA_LOCATION = "/mnt/storage/.services/vaultwarden/data";
    };

    script = "${pkgs.docker-compose}/bin/docker-compose -f ${./docker-compose.yml} up";

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "traefik-compose.service"];
  };
}
