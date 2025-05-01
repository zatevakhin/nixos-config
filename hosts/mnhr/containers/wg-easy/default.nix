{
  pkgs,
  config,
  hostname,
  ...
}: let
  domain = "wg.homeworld.lan";
in {
  services.adguardhome.settings.filtering.rewrites = [
    {
      domain = domain;
      answer = "${hostname}.lan";
    }
  ];

  sops.secrets.wireguard-domain = {
    sopsFile = ../../secrets/wg-easy.yaml;
    format = "yaml";
    key = "wireguard/domain";
  };

  sops.secrets.wireguard-ui-password = {
    sopsFile = ../../secrets/wg-easy.yaml;
    format = "yaml";
    key = "wireguard/ui/password_hash";
  };

  sops.templates."wg-easy-creds.env".content = ''
    WG_HOST=${config.sops.placeholder.wireguard-domain}
    PASSWORD_HASH='${config.sops.placeholder.wireguard-ui-password}'
  '';

  systemd.services.wg-easy-compose = {
    environment = {
      INTERNAL_DOMAIN_NAME = domain;
    };

    serviceConfig = {
      EnvironmentFile = config.sops.templates."wg-easy-creds.env".path;
    };

    script = "${pkgs.docker-compose}/bin/docker-compose -f ${./docker-compose.yml} up";

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "traefik.service"];
  };
}
