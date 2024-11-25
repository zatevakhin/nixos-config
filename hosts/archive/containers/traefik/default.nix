{ pkgs, lib, config, ... }: let
  root_ca = "/root/.step/certs/root_ca.crt";
in {

  systemd.services.traefik-compose = {
    environment = {
      TRAEFIK_CONFIG = ./traefik.yml;
      TRAEFIK_DYNAMIC_CONFIG = ./traefik_dynamic.yml;
      HOST_ROOT_CA = "${root_ca}";
      LEGO_CA_CERTIFICATES = "/etc/traefik/certs/root.crt";
    };

    unitConfig = {
      ConditionPathExists = [root_ca];
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
    requires = ["step-ca-bootstrap.service"];
    after = ["docker.service" "docker.socket" "step-ca-bootstrap.service"];
  };
}
