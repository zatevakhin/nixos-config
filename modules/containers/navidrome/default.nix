{...}: {
  flake.nixosModules.container-navidrome = {
    hostname,
    config,
    pkgs,
    lib,
    ...
  }: let
    TLD = "homeworld.lan";
    SERVICE = "navidrome";
  in {
    services.adguardhome.settings.filtering.rewrites = lib.mkIf config.services.adguardhome.enable [
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

    systemd.services.navidrome-compose = {
      environment = {
        INTERNAL_DOMAIN_NAME = "${SERVICE}.${TLD}";
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
  };
}
