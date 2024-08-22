{
  pkgs,
  lib,
  config,
  ...
}: {
  sops.secrets.wireguard-domain = {
    sopsFile = ../../secrets/pihole.yaml;
    format = "yaml";
    key = "wireguard/domain";
  };

  sops.secrets.wireguard-ui-password = {
    sopsFile = ../../secrets/pihole.yaml;
    format = "yaml";
    key = "wireguard/ui/password";
  };

  sops.secrets.pihole-ui-password = {
    sopsFile = ../../secrets/pihole.yaml;
    format = "yaml";
    key = "ui/password";
  };

  sops.templates."pihole-creds.env".content = ''
    WG_HOST=${config.sops.placeholder.wireguard-domain}
    PASSWORD=${config.sops.placeholder.wireguard-ui-password}
    WEBPASSWORD=${config.sops.placeholder.pihole-ui-password}
  '';

  systemd.services.pihole-compose = {
    serviceConfig = {
      EnvironmentFile = config.sops.templates."pihole-creds.env".path;
    };

    script = "${pkgs.docker-compose}/bin/docker-compose -f ${./docker-compose.yml} up";

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "sops-nix.service" "traefik-compose.service"];
  };
}
