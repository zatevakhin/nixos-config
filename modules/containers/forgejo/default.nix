{...}: {
  flake.nixosModules.container-forgejo = {
    hostname,
    config,
    pkgs,
    lib,
    ...
  }: let
    TLD = "homeworld.lan";
    SERVICE = "forgejo";
  in {
    assertions = [
      {
        assertion = config.virtualisation.docker.enable;
        message = "container-forgejo requires virtualisation.docker.enable";
      }
      {
        assertion = config.services.adguardhome.enable;
        message = "container-forgejo requires services.adguardhome.enable";
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

    systemd.services.forgejo-compose = {
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
