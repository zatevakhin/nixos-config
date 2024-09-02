{ pkgs, lib, config, ... }: {

  systemd.services.audiobookshelf-compose = {
    script = "${pkgs.docker-compose}/bin/docker-compose -f ${./docker-compose.yml} up";

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "traefik-compose.service"];
  };

}