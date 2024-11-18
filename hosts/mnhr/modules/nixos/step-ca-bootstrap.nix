{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.step-ca-bootstrap;
in {
  options.services.step-ca-bootstrap = {
    enable = lib.mkEnableOption "Step CA bootstrap service";

    ca-url = lib.mkOption {
      type = lib.types.str;
      description = "URL of the Step CA server";
      example = "https://ca.example.com:8443";
    };

    fingerprint = lib.mkOption {
      type = lib.types.str;
      description = "Fingerprint of the Step CA root certificate";
      example = "d9d0978692f1c7cc791f5c343ce98771900721405e834cd27b9502cc00aea2e1";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.step-ca-bootstrap = {
      description = "Bootstrap Step CA root certificate";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target"];
      wants = ["network-online.target"];

      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Group = "root";
        RemainAfterExit = true;
      };

      path = with pkgs; [
        step-cli
      ];

      environment = {
        HOME = "/root";
      };

      # TODO: Move `root_ca` to other place from `root` home.
      # Or better make it configurable?
      script = ''
        # Check if already bootstrapped by looking for root certificate
        if [ -f "/root/.step/certs/root_ca.crt" ]; then
          echo "Step CA already bootstrapped"
          exit 0
        fi

        # Create .step directory if it doesn't exist
        install -d -m 700 /root/.step
        install -d -m 700 /root/.step/certs

        # Bootstrap the CA
        step ca bootstrap \
          --ca-url ${cfg.ca-url} \
          --fingerprint "${cfg.fingerprint}" \
          --force
      '';

      preStop = ''
        echo "Cleaning up Step CA bootstrap files..."
        rm -rf /root/.step
      '';
    };
  };
}
