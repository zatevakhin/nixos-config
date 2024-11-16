{pkgs, ...}: let
  dashboard-icons = pkgs.callPackage ../../../../modules/packages/dashboard-icons {};
in {
  environment.systemPackages = [
    dashboard-icons
  ];

  systemd.services.glance-compose = {
    environment = {
      GLANCE_CONFIG = ./glance.yml;
      SVG_ASSETS_HOST_LOCATION = "${dashboard-icons}/share/dashboard-icons/svg/";
      PNG_ASSETS_HOST_LOCATION = "${dashboard-icons}/share/dashboard-icons/png/";
    };

    script = "${pkgs.docker-compose}/bin/docker-compose -f ${./docker-compose.yml} up";

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "traefik-compose.service"];
  };
}
