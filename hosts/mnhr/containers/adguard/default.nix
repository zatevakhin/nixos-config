{
  pkgs,
  config,
  dns,
  ...
}: {
  # TODO: Split docker-compose in adguard and wireguard
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

  systemd.services.adguard-compose = {
    serviceConfig = {
      EnvironmentFile = config.sops.templates."wg-easy-creds.env".path;
    };

    environment = {
      DOCKER_DNS_IP = "${dns}";
    };

    script = "${pkgs.docker-compose}/bin/docker-compose -f ${./docker-compose.yml} up";

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "sops-nix.service" "traefik.service"];
  };
}
