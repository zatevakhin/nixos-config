{
  pkgs,
  config,
  dns,
  ...
}: let
  dashboard-icons = pkgs.callPackage ../../../../modules/packages/dashboard-icons {};
in {
  environment.systemPackages = [
    dashboard-icons
  ];

  sops.secrets.adguard-password = {
    sopsFile = ../../secrets/adguard.yaml;
    format = "yaml";
    key = "password";
  };

  sops.templates."adguard-creds.env".content = ''
    ADGUARD_PASSWORD=${config.sops.placeholder.adguard-password}
  '';

  systemd.services.glance-compose = {
    serviceConfig = {
      EnvironmentFile = config.sops.templates."adguard-creds.env".path;
    };

    environment = {
      DOCKER_DNS_IP = "${dns}";
      GLANCE_CONFIG = ./glance.yml;
      SVG_ASSETS_HOST_LOCATION = "${dashboard-icons}/share/dashboard-icons/svg/";
      PNG_ASSETS_HOST_LOCATION = "${dashboard-icons}/share/dashboard-icons/png/";
    };

    script = "${pkgs.docker-compose}/bin/docker-compose -f ${./docker-compose.yml} up";

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "traefik.service" "adguard-compose.service"];
    requires = ["docker.service" "traefik.service" "adguard-compose.service"];
  };
}
