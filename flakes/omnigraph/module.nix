{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.omnigraph;
  defaultPackage = (pkgs.callPackage ./package.nix {}).omnigraph-server;
in {
  options.services.omnigraph = {
    enable = lib.mkEnableOption "Omnigraph server";

    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPackage;
      defaultText = lib.literalExpression "(pkgs.callPackage ./package.nix {}).omnigraph-server";
      description = "Omnigraph server package to run.";
    };

    cluster = lib.mkOption {
      type = lib.types.path;
      description = "Path to the cluster configuration directory containing cluster.yaml.";
      example = lib.literalExpression "./company-brain";
    };

    bindAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Address on which omnigraph-server listens.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "TCP port on which omnigraph-server listens.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open the configured TCP port in the firewall.";
    };

    environment = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = {
        AWS_ENDPOINT_URL = "http://127.0.0.1:9000";
        AWS_REGION = "us-east-1";
      };
      description = "Non-secret environment variables for omnigraph-server.";
    };

    environmentFiles = lib.mkOption {
      type = lib.types.listOf lib.types.path;
      default = [];
      description = "systemd EnvironmentFile files, suitable for secrets such as S3 credentials.";
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional command-line arguments passed to omnigraph-server.";
    };
  };

  config = lib.mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [cfg.port];

    systemd.services.omnigraph = {
      description = "Omnigraph server";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];

      environment = cfg.environment;
      serviceConfig = {
        ExecStart = lib.escapeShellArgs (
          [
            "${cfg.package}/bin/omnigraph-server"
            "--cluster"
            (toString cfg.cluster)
            "--bind"
            "${cfg.bindAddress}:${toString cfg.port}"
          ]
          ++ cfg.extraArgs
        );
        EnvironmentFile = cfg.environmentFiles;
        DynamicUser = true;
        StateDirectory = "omnigraph";
        WorkingDirectory = "/var/lib/omnigraph";
        Restart = "on-failure";
        RestartSec = 5;
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadOnlyPaths = [cfg.cluster];
      };
    };
  };
}
