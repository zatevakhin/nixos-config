{pkgs, ...}: let
  cert = "/var/lib/traefik/certs/homeworld-wildcard.crt";
  key = "/var/lib/traefik/certs/homeworld-wildcard.key";
in {
  systemd.services.traefik-compose = {
    environment = {
      TRAEFIK_CONFIG = ./traefik.yml;
      TRAEFIK_TLS_DYNAMIC_CONFIG = ./tls.yml;
      TRAEFIK_TLS_CERT = "${cert}";
      TRAEFIK_TLS_CERT_KEY = "${key}";
    };

    unitConfig = {
      ConditionPathExists = [cert key];
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
    requires = ["step-certificates.service"];
    after = ["docker.service" "docker.socket" "step-certificates.service"];
  };
}
