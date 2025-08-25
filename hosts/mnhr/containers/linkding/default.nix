{
  config,
  lib,
  pkgs,
  hostname,
  ...
}:
with lib; let
  cfg = config.services.linkding-compose;
in {
  options.services.linkding-compose = {
    enable = mkEnableOption "Linkding Docker Compose service";

    domain = mkOption {
      type = types.str;
      default = "linkding.homeworld.lan";
      description = "Domain name for the Linkding service";
    };

    compose_file = mkOption {
      type = types.path;
      default = ./docker-compose.yml;
      description = "Path to the docker-compose.yml file";
    };

    secrets_file = mkOption {
      type = types.path;
      description = "Path to the SOPS secrets file for Linkding";
    };

    enable_adguard_rewrite = mkOption {
      type = types.bool;
      default = true;
      description = "Whether to add AdGuard Home rewrite rule";
    };

    systemd = {
      restart = mkOption {
        type = types.str;
        default = "on-failure";
        description = "Systemd restart policy";
      };

      restart_sec = mkOption {
        type = types.int;
        default = 5;
        description = "Time to wait before restarting the service";
      };

      start_limit_burst = mkOption {
        type = types.int;
        default = 3;
        description = "Number of restart attempts within the interval";
      };

      start_limit_interval_sec = mkOption {
        type = types.int;
        default = 60;
        description = "Time interval for restart attempts";
      };
    };
  };

  config = mkIf cfg.enable {
    services.adguardhome.settings.filtering.rewrites = mkIf cfg.enable_adguard_rewrite [
      {
        domain = cfg.domain;
        answer = "${hostname}.lan";
      }
    ];

    sops.secrets.linkding-superuser-user = {
      sopsFile = cfg.secrets_file;
      format = "yaml";
      key = "linkding/user";
    };

    sops.secrets.linkding-superuser-password = {
      sopsFile = cfg.secrets_file;
      format = "yaml";
      key = "linkding/password";
    };

    sops.templates."linkding-creds.env".content = ''
      LD_SUPERUSER_NAME=${config.sops.placeholder.linkding-superuser-user}
      LD_SUPERUSER_PASSWORD=${config.sops.placeholder.linkding-superuser-password}
    '';

    systemd.services.linkding-compose = {
      environment = {
        INTERNAL_DOMAIN_NAME = cfg.domain;
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose --file ${cfg.compose_file} up";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose --file ${cfg.compose_file} stop";
        EnvironmentFile = config.sops.templates."linkding-creds.env".path;
        StandardOutput = "syslog";
        Restart = cfg.systemd.restart;
        RestartSec = cfg.systemd.restart_sec;
        StartLimitIntervalSec = cfg.systemd.start_limit_interval_sec;
        StartLimitBurst = cfg.systemd.start_limit_burst;
      };

      wantedBy = ["multi-user.target"];
      after = ["docker.service" "docker.socket" "traefik.service"];
    };
  };
}
