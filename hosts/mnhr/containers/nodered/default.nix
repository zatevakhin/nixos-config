{
  pkgs,
  hostname,
  ...
}: let
  domain = "nodered.homeworld.lan";
in {
  services.adguardhome.settings.filtering.rewrites = [
    {
      domain = domain;
      answer = "${hostname}.lan";
    }
  ];

  systemd.services.nodered-compose = {
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

    environment = {
      INTERNAL_DOMAIN_NAME = domain;
      NODE_RED_SETTINGS_JS = ./settings.js;
      # TODO: Set certificate from host side preferably in `settings.js`.
      NODE_RED_DOCKERFILE = ./Dockerfile;
    };

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "traefik-compose.service"];
  };
}
