{
  config,
  lib,
  pkgs,
  hostname,
  ...
}:
with lib; let
  cfg = config.services.nodered-compose;
in {
  options.services.nodered-compose = {
    enable = mkEnableOption "Node-RED Docker Compose service";

    domain = mkOption {
      type = types.str;
      default = "nodered.homeworld.lan";
      description = "Domain name for the Node-RED service";
    };

    compose_file = mkOption {
      type = types.path;
      default = ./docker-compose.yml;
      description = "Path to the docker-compose.yml file";
    };

    settings_js = mkOption {
      type = types.path;
      default = ./settings.js;
      description = "Path to the Node-RED settings.js file";
    };

    dockerfile = mkOption {
      type = types.path;
      default = ./Dockerfile;
      description = "Path to the Node-RED Dockerfile";
    };

    enable_adguard_rewrite = mkOption {
      type = types.bool;
      default = false;
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

    systemd.services.nodered-compose = {
      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose --file ${cfg.compose_file} up";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose --file ${cfg.compose_file} stop";
        StandardOutput = "syslog";
        Restart = cfg.systemd.restart;
        RestartSec = cfg.systemd.restart_sec;
        StartLimitIntervalSec = cfg.systemd.start_limit_interval_sec;
        StartLimitBurst = cfg.systemd.start_limit_burst;
      };

      environment = {
        INTERNAL_DOMAIN_NAME = cfg.domain;
        NODE_RED_SETTINGS_JS = cfg.settings_js;
        # TODO: Set certificate from host side preferably in `settings.js`.
        NODE_RED_DOCKERFILE = cfg.dockerfile;
      };

      wantedBy = ["multi-user.target"];
      after = ["docker.service" "docker.socket" "traefik-compose.service"];
    };
  };
}
