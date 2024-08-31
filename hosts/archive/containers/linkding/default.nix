{
  pkgs,
  lib,
  config,
  ...
}: {
  sops.secrets.linkding-superuser-user = {
    sopsFile = ../../secrets/linkding.yaml;
    format = "yaml";
    key = "linkding/user";
  };

  sops.secrets.linkding-superuser-password = {
    sopsFile = ../../secrets/linkding.yaml;
    format = "yaml";
    key = "linkding/password";
  };

  sops.templates."linkding-creds.env".content = ''
    LD_SUPERUSER_NAME=${config.sops.placeholder.linkding-superuser-user}
    LD_SUPERUSER_PASSWORD=${config.sops.placeholder.linkding-superuser-password}
  '';

  systemd.services.linkding-compose = {
    serviceConfig = {
      EnvironmentFile = config.sops.templates."linkding-creds.env".path;
    };

    script = "${pkgs.docker-compose}/bin/docker-compose -f ${./docker-compose.yml} up";

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "traefik-compose.service"];
  };
}
