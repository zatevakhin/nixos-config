{pkgs, ...}: {
  systemd.services.ollama-compose = {
    script = "${pkgs.docker-compose}/bin/docker-compose -f ${./docker-compose.yml} up --build";

    environment = {
      OLLAMA_KEEP_ALIVE = "5m";
      OLLAMA_FLASH_ATTENTION = "1";
      # NOTE: When multiple GPUs, for scheduling across all GPUs.
      # OLLAMA_SCHED_SPREAD = "1";
    };

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket"];
  };

  networking.firewall.allowedTCPPorts = [11434];
}
