{
  pkgs,
  config,
  hostname,
  ...
}: let
  domain = "linkding.homeworld.lan";
in {
  services.adguardhome.settings.filtering.rewrites = [
    {
      domain = domain;
      answer = "${hostname}.lan";
    }
  ];
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
    environment = {
      INTERNAL_DOMAIN_NAME = domain;
    };

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose --file ${./docker-compose.yml} up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose --file ${./docker-compose.yml} stop";
      EnvironmentFile = config.sops.templates."linkding-creds.env".path;
      StandardOutput = "syslog";
      Restart = "on-failure";
      RestartSec = 5;
      StartLimitIntervalSec = 60;
      StartLimitBurst = 3;
    };

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "traefik.service"];
  };
}
