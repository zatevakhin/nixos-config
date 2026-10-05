{...}: {
  flake.nixosModules.container-linkding = {
    hostname,
    config,
    pkgs,
    lib,
    ...
  }: let
    TLD = "homeworld.lan";
    SERVICE = "linkding";
  in {
    assertions = [
      {
        assertion = config.virtualisation.docker.enable;
        message = "container-linkding requires virtualisation.docker.enable";
      }
      {
        assertion = config.services.adguardhome.enable;
        message = "container-linkding requires services.adguardhome.enable";
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

    sops.secrets.linkding-superuser-user = {
      sopsFile = ../../../secrets/${hostname}/linkding.yaml;
      format = "yaml";
      key = "linkding/user";
    };

    sops.secrets.linkding-superuser-password = {
      sopsFile = ../../../secrets/${hostname}/linkding.yaml;
      format = "yaml";
      key = "linkding/password";
    };

    sops.templates."linkding-creds.env".content = ''
      LD_SUPERUSER_NAME=${config.sops.placeholder.linkding-superuser-user}
      LD_SUPERUSER_PASSWORD=${config.sops.placeholder.linkding-superuser-password}
    '';

    systemd.services.linkding-compose = {
      environment = {
        INTERNAL_DOMAIN_NAME = "${SERVICE}.${TLD}";
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose --file ${./docker-compose.yml} up";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose --file ${./docker-compose.yml} stop";
        EnvironmentFile = config.sops.templates."linkding-creds.env".path;
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
