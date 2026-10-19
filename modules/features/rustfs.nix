{inputs, ...}: {
  flake.nixosModules.rustfs = {
    config,
    lib,
    pkgs,
    pkgs-unstable,
    ...
  }: let
    cfg = config.services.rustfs;
    provision = cfg.provisioning;
  in {
    imports = [
      "${inputs.nixpkgs-unstable}/nixos/modules/services/web-servers/rustfs.nix"
    ];

    options.services.rustfs.provisioning = {
      buckets = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [];
        description = "S3 buckets to create if missing. An empty list disables initialization.";
      };
      endpoint = lib.mkOption {
        type = lib.types.str;
        description = "Local RustFS HTTP endpoint used for health checks and bucket initialization.";
      };
      region = lib.mkOption {
        type = lib.types.str;
        default = "us-east-1";
        description = "S3 region used for bucket initialization.";
      };
    };

    config = {
      services.rustfs.package = lib.mkDefault pkgs-unstable.rustfs;

      services.rustfs.settings = lib.mkIf cfg.enable {
        RUSTFS_CONSOLE_ENABLE = lib.mkDefault "true";
        RUSTFS_OBS_LOG_DIRECTORY = lib.mkDefault "/var/log/rustfs";
        RUSTFS_OBS_LOGGER_LEVEL = lib.mkDefault "info";
      };

      systemd.services.rustfs = lib.mkIf cfg.enable {
        serviceConfig = {
          StateDirectory = "rustfs";
          LogsDirectory = "rustfs";
          WorkingDirectory = "/var/lib/rustfs";
        };
        preStart = lib.mkAfter ''
          case "$RUSTFS_ACCESS_KEY:$RUSTFS_SECRET_KEY" in
            *REPLACE_ME_*)
              echo "Replace the RustFS SOPS placeholders before starting the service" >&2
              exit 1
              ;;
          esac
        '';
      };

      # Provision only explicitly requested buckets; leave existing contents intact.
      systemd.services.rustfs-init = lib.mkIf (cfg.enable && provision.buckets != []) {
        description = "Ensure configured RustFS S3 buckets exist";
        wantedBy = ["multi-user.target"];
        requires = ["rustfs.service"];
        after = ["rustfs.service"];
        partOf = ["rustfs.service"];
        path = [pkgs.curl pkgs.awscli2];
        environment = {
          AWS_REGION = provision.region;
          AWS_EC2_METADATA_DISABLED = "true";
          AWS_PAGER = "";
          AWS_MAX_ATTEMPTS = "3";
          AWS_CONFIG_FILE = "/dev/null";
          AWS_SHARED_CREDENTIALS_FILE = "/dev/null";
        };
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          User = cfg.user;
          Group = cfg.group;
          EnvironmentFile = cfg.environmentFile;
          TimeoutStartSec = "300s";
          NoNewPrivileges = true;
          PrivateTmp = true;
          ProtectHome = true;
          ProtectSystem = "strict";
        };
        script = ''
          set -euo pipefail
          endpoint=${lib.escapeShellArg provision.endpoint}
          curl --fail --silent --show-error --retry 12 --retry-all-errors \
            --retry-delay 5 --retry-max-time 120 --max-time 5 \
            --output /dev/null "$endpoint/health"
          export AWS_ACCESS_KEY_ID="$RUSTFS_ACCESS_KEY"
          export AWS_SECRET_ACCESS_KEY="$RUSTFS_SECRET_KEY"
          buckets=(${lib.escapeShellArgs provision.buckets})
          for bucket in "''${buckets[@]}"; do
            if ! aws --endpoint-url "$endpoint" s3api head-bucket --bucket "$bucket" 2>/dev/null; then
              aws --endpoint-url "$endpoint" s3api create-bucket --bucket "$bucket" >/dev/null
            fi
            aws --endpoint-url "$endpoint" s3api head-bucket --bucket "$bucket"
          done
        '';
      };
    };
  };
}
