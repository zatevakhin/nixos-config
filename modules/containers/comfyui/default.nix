{...}: {
  flake.nixosModules.container-comfyui = {
    config,
    pkgs,
    lib,
    ...
  }: {
    assertions = [
      {
        assertion = config.virtualisation.docker.enable;
        message = "container-comfyui requires virtualisation.docker.enable";
      }
      {
        assertion = config.hardware.nvidia-container-toolkit.enable;
        message = "container-comfyui requires hardware.nvidia-container-toolkit.enable";
      }
    ];

    networking.firewall.allowedTCPPorts = [8188];

    systemd.services.comfyui-compose = {
      environment = {
        CLI_ARGS = "--listen 0.0.0.0";
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose --file ${./docker-compose.yml} up";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose --file ${./docker-compose.yml} stop";
        StandardOutput = "journal";
        Restart = "on-failure";
        RestartSec = 5;
        StartLimitBurst = 3;
      };

      # Heavy GPU workload; start on demand (same as the old module).
      wantedBy = lib.mkForce [];
      after = ["docker.service" "docker.socket"];
    };
  };
}
