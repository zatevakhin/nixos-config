{pkgs, ...}: {
  systemd.services.comfyui-compose = {
    script = "${pkgs.docker-compose}/bin/docker-compose -f ${./docker-compose.yml} up";

    environment = {
      CLI_ARGS = "--listen 0.0.0.0";
    };

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket"];
  };

  networking.firewall.allowedTCPPorts = [8188];
}
