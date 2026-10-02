{...}: {
  flake.nixosModules.container-forgejo = {
    hostname,
    config,
    pkgs,
    lib,
    ...
  }: let
    TLD = "homeworld.lan";
    SERVICE = "forgejo";
    cfg = config.services.forgejo-compose;
    sshEnabled = cfg.sshPort != null;
    sshComposeFile = pkgs.writeText "forgejo-ssh-compose.yml" ''
      services:
        server:
          environment:
            - FORGEJO__server__DISABLE_SSH=false
            - FORGEJO__server__START_SSH_SERVER=false
            - FORGEJO__server__SSH_DOMAIN=${SERVICE}.${TLD}
            - FORGEJO__server__SSH_PORT=${toString cfg.sshPort}
            - FORGEJO__server__SSH_USER=git
          labels:
            - traefik.tcp.routers.forgejo-ssh.entrypoints=forgejo-ssh
            - traefik.tcp.routers.forgejo-ssh.rule=HostSNI(`*`)
            - traefik.tcp.routers.forgejo-ssh.service=forgejo-ssh
            - traefik.tcp.services.forgejo-ssh.loadbalancer.server.port=22
    '';
    composeFiles =
      "--file ${./docker-compose.yml}"
      + lib.optionalString sshEnabled " --file ${sshComposeFile}";
  in {
    options.services.forgejo-compose.sshPort = lib.mkOption {
      type = lib.types.nullOr lib.types.port;
      default = null;
      description = "SSH port exposed through Traefik, or null to leave SSH routing unchanged.";
    };

    config = {
      assertions = [
        {
          assertion = config.virtualisation.docker.enable;
          message = "container-forgejo requires virtualisation.docker.enable";
        }
        {
          assertion = config.services.adguardhome.enable;
          message = "container-forgejo requires services.adguardhome.enable";
        }
        {
          assertion = sshEnabled -> config.services.traefik.enable;
          message = "container-forgejo SSH routing requires services.traefik.enable";
        }
      ];

      services.adguardhome.settings.filtering.rewrites = [
        {
          domain = "${SERVICE}.${TLD}";
          answer = "${hostname}.lan";
          enabled = true;
        }
        {
          domain = "${SERVICE}-${hostname}.${TLD}";
          answer = "${hostname}.lan";
          enabled = true;
        }
      ];

      services.traefik.staticConfigOptions.entryPoints = lib.mkIf sshEnabled {
        forgejo-ssh.address = ":${toString cfg.sshPort}";
      };
      networking.firewall.allowedTCPPorts = lib.optional sshEnabled cfg.sshPort;

      systemd.services.forgejo-compose = {
        environment = {
          INTERNAL_DOMAIN_NAME = "${SERVICE}.${TLD}";
        };

        serviceConfig = {
          Type = "simple";
          ExecStart = "${pkgs.docker-compose}/bin/docker-compose ${composeFiles} up";
          ExecStop = "${pkgs.docker-compose}/bin/docker-compose ${composeFiles} stop";
          StandardOutput = "journal";
          Restart = "on-failure";
          RestartSec = 5;
          StartLimitBurst = 3;
        };

        wantedBy = ["multi-user.target"];
        after = ["docker.service" "docker.socket" "traefik.service"];
      };
    };
  };
}
