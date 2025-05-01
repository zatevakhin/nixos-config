{
  pkgs,
  hostname,
  ...
}: let
  domain = "ntfy.homeworld.lan";
in {
  services.adguardhome.settings.filtering.rewrites = [
    {
      domain = domain;
      answer = "${hostname}.lan";
    }
  ];

  systemd.services.ntfy-compose = {
    environment = {
      INTERNAL_DOMAIN_NAME = domain;
    };

    script = "${pkgs.docker-compose}/bin/docker-compose -f ${./docker-compose.yml} up";

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "traefik.service" "adguard-compose.service"];
    requires = ["docker.service" "traefik.service" "adguard-compose.service"];
  };
}
