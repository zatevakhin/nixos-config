{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.omnigraph;
  packages = pkgs.callPackage ./package.nix {};
  clusterBundle = builtins.path {
    path = cfg.bootstrap.configDirectory;
    name = "omnigraph-cluster";
  };
  exportAliases = lib.concatStringsSep "\n" (lib.mapAttrsToList (target: source: "export ${target}=\"$" + source + "\"") cfg.environmentAliases);
  serverCommand = lib.escapeShellArgs (
    [
      "${cfg.package}/bin/omnigraph-server"
      "--cluster"
      cfg.cluster
      "--bind"
      "${cfg.bindAddress}:${toString cfg.port}"
    ]
    ++ cfg.extraArgs
  );
  startServer = pkgs.writeShellScript "omnigraph-start" ''
    set -euo pipefail
    ${exportAliases}
    exec ${serverCommand}
  '';
in {
  options.services.omnigraph = {
    enable = lib.mkEnableOption "Omnigraph server";

    package = lib.mkOption {
      type = lib.types.package;
      default = packages.omnigraph-server;
      defaultText = lib.literalExpression "(pkgs.callPackage ./package.nix {}).omnigraph-server";
      description = "Omnigraph server package to run.";
    };

    cluster = lib.mkOption {
      type = lib.types.str;
      description = "Cluster configuration directory or applied storage-root URI (file:// or s3://).";
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

    environmentAliases = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Map environment variable names to variables loaded from environmentFiles, without copying secret values into Nix.";
    };

    bootstrap = {
      enable = lib.mkEnableOption "one-time initialization of a missing cluster ledger before serving";
      configDirectory = lib.mkOption {
        type = lib.types.path;
        description = "Cluster bundle to validate and apply only when the storage root has no ledger. Existing clusters are never automatically reapplied.";
      };
      cliPackage = lib.mkOption {
        type = lib.types.package;
        default = packages.omnigraph-cli;
        description = "Omnigraph CLI package matching the server version.";
      };
      actor = lib.mkOption {
        type = lib.types.str;
        description = "Direct-storage operator attribution for the initial cluster apply.";
      };
    };

    extraArgs = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional command-line arguments passed to omnigraph-server.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion =
          builtins.all (name: builtins.match "[A-Za-z_][A-Za-z0-9_]*" name != null)
          ((builtins.attrNames cfg.environmentAliases) ++ (builtins.attrValues cfg.environmentAliases));
        message = "Omnigraph environment aliases must contain valid environment variable names.";
      }
    ];

    networking.firewall.allowedTCPPorts = lib.optionals cfg.openFirewall [cfg.port];

    systemd.services.omnigraph = {
      description = "Omnigraph server";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];

      environment = cfg.environment;
      path = lib.optionals cfg.bootstrap.enable [cfg.bootstrap.cliPackage pkgs.jq pkgs.coreutils pkgs.gnused pkgs.curl];
      preStart = lib.mkIf cfg.bootstrap.enable ''
        set -euo pipefail
        ${exportAliases}
        bundle=${lib.escapeShellArg "${clusterBundle}"}
        root=${lib.escapeShellArg cfg.cluster}
        omnigraph cluster validate --config "$bundle"
        work=$(mktemp -d)
        trap 'rm -rf -- "$work"' EXIT
        if omnigraph --cluster "$root" cluster status --json > "$work/status.json" 2> "$work/status.log"; then
          if ! jq -e --arg root "$root" '.canonical_root == $root and (.ledger_id | type == "string") and .outstanding_id == null and .lock_id == null' "$work/status.json" >/dev/null; then
            echo "Omnigraph cluster has an existing owner, outstanding deployment, or unexpected ledger; refusing automatic recovery" >&2
            exit 1
          fi
          exit 0
        fi
        # Never bootstrap on permission, network, corrupt-state, or lock errors.
        if ! jq -e '.ok == false and (.diagnostics | length == 1) and .diagnostics[0].code == "state_missing"' "$work/status.json" >/dev/null; then
          cat "$work/status.log" >&2
          cat "$work/status.json" >&2
          exit 1
        fi
        if ! omnigraph --as ${lib.escapeShellArg cfg.bootstrap.actor} cluster apply \
          --config "$bundle" --json > "$work/apply.json" 2> "$work/apply.log"; then
          cat "$work/apply.log" >&2
          cat "$work/apply.json" >&2
          exit 1
        fi
        jq -e '.status == "complete" and .result.converged == true' "$work/apply.json" >/dev/null
        lock_id=$(sed -n 's/^Admission lock: \([^; ]*\);.*/\1/p' "$work/apply.log")
        applied_root=$(sed -n 's/^Cluster-root: //p' "$work/apply.log")
        test -n "$lock_id"
        test "$applied_root" = "$root"
        # This CLI has exited successfully: hand off only its own exact lock.
        omnigraph --cluster "$root" cluster force-unlock "$lock_id" --json
      '';
      postStart = lib.mkIf cfg.bootstrap.enable ''
        set -euo pipefail
        ${exportAliases}
        curl --fail --silent --show-error --retry 30 --retry-all-errors \
          --retry-delay 1 --retry-max-time 90 --max-time 5 \
          --output /dev/null http://127.0.0.1:${toString cfg.port}/readyz
        root=${lib.escapeShellArg cfg.cluster}
        lock_id=$(omnigraph --cluster "$root" cluster status --json \
          | jq -er --arg root "$root" 'select(.canonical_root == $root) | .lock_id | select(type == "string" and length > 0)')
        printf '%s\n' "$lock_id" > "$RUNTIME_DIRECTORY/writer-lock"
      '';
      postStop = lib.mkIf cfg.bootstrap.enable ''
        set -euo pipefail
        # Release only the recorded owner after a successful, settled shutdown.
        if [ "''${SERVICE_RESULT:-}" != "success" ] || [ "''${EXIT_CODE:-}" != "exited" ] \
          || [ "''${EXIT_STATUS:-}" != "0" ] || [ ! -s "$RUNTIME_DIRECTORY/writer-lock" ]; then
          exit 0
        fi
        ${exportAliases}
        lock_id=$(cat "$RUNTIME_DIRECTORY/writer-lock")
        omnigraph --cluster ${lib.escapeShellArg cfg.cluster} cluster force-unlock "$lock_id" --json
        rm -- "$RUNTIME_DIRECTORY/writer-lock"
      '';
      serviceConfig = {
        Type = "exec";
        ExecStart = "${startServer}";
        EnvironmentFile = cfg.environmentFiles;
        DynamicUser = true;
        StateDirectory = "omnigraph";
        RuntimeDirectory = lib.mkIf cfg.bootstrap.enable "omnigraph";
        RuntimeDirectoryMode = "0700";
        WorkingDirectory = "/var/lib/omnigraph";
        Restart = "on-failure";
        RestartSec = 5;
        TimeoutStartSec = "600s";
        TimeoutStopSec = "60s";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        ReadOnlyPaths =
          lib.optionals cfg.bootstrap.enable [clusterBundle]
          ++ lib.optional (lib.hasPrefix "/" cfg.cluster) cfg.cluster;
      };
    };
  };
}
