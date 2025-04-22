{
  pkgs,
  dns,
  ...
}: {
  systemd.services.adguard-compose = {
    environment = {
      DOCKER_DNS_IP = "${dns}";
    };

    script = "${pkgs.docker-compose}/bin/docker-compose -f ${./docker-compose.yml} up";

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "sops-nix.service" "traefik.service"];
  };
}
