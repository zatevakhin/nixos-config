{pkgs, ...}: {
  systemd.services.nodered-compose = {
    script = "${pkgs.docker-compose}/bin/docker-compose -f ${./docker-compose.yml} up --build";

    environment = {
      NODE_RED_SETTINGS_JS = ./settings.js;
      # TODO: Set certificate from host side preferably in `settings.js`.
      NODE_RED_DOCKERFILE = ./Dockerfile;
    };

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "traefik-compose.service"];
  };
}
