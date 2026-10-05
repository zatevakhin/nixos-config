{...}: {
  flake.nixosModules.container-immich = {
    lib,
    pkgs,
    config,
    hostname,
    ...
  }: let
    TLD = "homeworld.lan";
    SERVICE = "immich";
  in {
    assertions = [
      {
        assertion = config.virtualisation.docker.enable;
        message = "container-immich requires virtualisation.docker.enable";
      }
      {
        assertion = config.services.adguardhome.enable;
        message = "container-immich requires services.adguardhome.enable";
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

    systemd.services.immich-compose = {
      environment = {
        INTERNAL_DOMAIN_NAME = "${SERVICE}.${TLD}";
        IMMICH_VERSION = "v3.1.0";
        IMMICH_HOST = "0.0.0.0";
        DB_PASSWORD = "postgres";
        TZ = "Europe/Lisbon";

        UPLOAD_LOCATION = "/storage/.services/immich/data";
        DB_DATA_LOCATION = "/storage/.services/immich/db";

        DB_USERNAME = "postgres";
        DB_DATABASE_NAME = "immich";
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
