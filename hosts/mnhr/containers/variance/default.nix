{pkgs, ...}: {
  systemd.services.variance-compose = {
    script = "${pkgs.docker-compose}/bin/docker-compose -f ${./docker-compose.yml} up --build";

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "traefik.service" "adguard-compose.service"];
    requires = ["docker.service" "traefik.service" "adguard-compose.service"];
  };
}
