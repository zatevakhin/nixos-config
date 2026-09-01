{...}: {
  flake.nixosModules.container-vaultwarden = {
    hostname,
    config,
    pkgs,
    lib,
    ...
  }: let
    TLD = "homeworld.lan";
    SERVICE = "vw";
  in {
    assertions = [
      {
        assertion = config.virtualisation.docker.enable;
        message = "container-vaultwarden requires virtualisation.docker.enable";
      }
      {
        assertion = config.services.adguardhome.enable;
        message = "container-vaultwarden requires services.adguardhome.enable";
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

    sops.secrets.vaultwarden-admin-token = {
      sopsFile = ../../../secrets/${hostname}/vaultwarden.yaml;
      format = "yaml";
      key = "admin/token";
    };

    sops.templates."vaultwarden.env".content = ''
      ADMIN_TOKEN=${config.sops.placeholder.vaultwarden-admin-token}
    '';

    systemd.services.vaultwarden-compose = {
      environment = {
        SIGNUPS_ALLOWED = "false";
        ENABLE_WEBSOCKET = "true";
        INVITATIONS_ALLOWED = "false";
        ICON_SERVICE = "duckduckgo";
        INTERNAL_DOMAIN_NAME = "${SERVICE}.${TLD}";
        VAULTWARDEN_DATA_LOCATION = "/storage/.services/vaultwarden/data";
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose --file ${./docker-compose.yml} up";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose --file ${./docker-compose.yml} stop";
        EnvironmentFile = config.sops.templates."vaultwarden.env".path;
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
