{...}: {
  flake.nixosModules.container-restreamer = {
    hostname,
    config,
    pkgs,
    ...
  }: let
    TLD = "homeworld.lan";
    SERVICE = "restreamer";
  in {
    assertions = [
      {
        assertion = config.virtualisation.docker.enable;
        message = "container-restreamer requires virtualisation.docker.enable";
      }
      {
        assertion = config.services.adguardhome.enable;
        message = "container-restreamer requires services.adguardhome.enable";
      }
    ];

    services.adguardhome.settings.filtering.rewrites = [
      {
        domain = "${SERVICE}.${TLD}";
        answer = "${hostname}.lan";
        enabled = true;
      }
      {
        domain = "${SERVICE}-${hostname}.${TLD}";
        answer = "${hostname}.lan";
        enabled = true;
      }
    ];

    systemd.services.restreamer-compose = {
      environment = {
        INTERNAL_DOMAIN_NAME = "${SERVICE}.${TLD}";
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose --file ${./docker-compose.yml} up";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose --file ${./docker-compose.yml} stop";
        StandardOutput = "journal";
        Restart = "on-failure";
        RestartSec = 5;
        StartLimitBurst = 3;
      };

      wantedBy = ["multi-user.target"];
      after = ["docker.service" "docker.socket" "traefik.service"];
    };
  };
}
