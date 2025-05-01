{
  pkgs,
  hostname,
  ...
}: let
  domain = "searxng.homeworld.lan";
in {
  services.adguardhome.settings.filtering.rewrites = [
    {
      domain = domain;
      answer = "${hostname}.lan";
    }
  ];

  systemd.services.searxng-compose = {
    environment = {
      INTERNAL_DOMAIN_NAME = domain;
    };

    script = "${pkgs.docker-compose}/bin/docker-compose -f ${./docker-compose.yml} up";

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "traefik.service"];
  };
}
