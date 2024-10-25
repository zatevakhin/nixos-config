{pkgs, ...}: {
  systemd.services.traefik-compose = {
    environment = {
      TRAEFIK_CONFIG = ./traefik.yml;
    };

    script = ''
      network_name="proxy"
      subnet="10.0.1.0/24"

      if ! ${pkgs.docker}/bin/docker network ls --format '{{.Name}}' | grep -wq "$network_name"; then
          ${pkgs.docker}/bin/docker network create --subnet "$subnet" "$network_name"

          if [ $? -ne 0 ]; then
            echo "Failed to create network '$network_name' with subnet '$subnet'."
            exit 1
          fi
      fi

      ${pkgs.docker-compose}/bin/docker-compose -f ${./docker-compose.yml} up
    '';

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket"];
  };
}
