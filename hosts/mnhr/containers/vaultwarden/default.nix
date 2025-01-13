{
  pkgs,
  config,
  ...
}: {
  sops.secrets.vaultwarden-admin-token = {
    sopsFile = ../../secrets/vaultwarden.yaml;
    format = "yaml";
    key = "admin/token";
  };

  sops.templates."vaultwarden.env".content = ''
    ADMIN_TOKEN=${config.sops.placeholder.vaultwarden-admin-token}
  '';

  systemd.services.vaultwarden-compose = {
    serviceConfig = {
      EnvironmentFile = config.sops.templates."vaultwarden.env".path;
    };

    environment = {
      SIGNUPS_ALLOWED = "false";
      INVITATIONS_ALLOWED = "false";
      ICON_SERVICE = "duckduckgo";
      VAULTWARDEN_DOMAIN = "vw.homeworld.lan";
      VAULTWARDEN_DATA_LOCATION = "/mnt/storage/.services/vaultwarden/data";
    };

    script = "${pkgs.docker-compose}/bin/docker-compose -f ${./docker-compose.yml} up";

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "traefik.service"];
  };
}
