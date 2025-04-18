{pkgs, ...}: {
  systemd.services.watchtower-compose = {
    script = "${pkgs.docker-compose}/bin/docker-compose -f ${./docker-compose.yml} up";

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket"];
  };
}
