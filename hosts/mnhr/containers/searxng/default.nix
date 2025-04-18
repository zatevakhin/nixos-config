{pkgs, ...}: {
  systemd.services.searxng-compose = {
    environment = {
      SEARXNG_HOSTNAME = "searxng.homeworld.lan";
    };

    script = "${pkgs.docker-compose}/bin/docker-compose -f ${./docker-compose.yml} up";

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "traefik.service" "adguard-compose.service"];
    requires = ["docker.service" "traefik.service" "adguard-compose.service"];
  };
}
