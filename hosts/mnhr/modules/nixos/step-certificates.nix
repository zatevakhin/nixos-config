{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.step-certificates;
in {
  options.services.step-certificates = {
    enable = lib.mkEnableOption "Step certificates generation service";

    ca-url = lib.mkOption {
      type = lib.types.str;
      description = "URL of the Step CA server";
      example = "https://ca.example.com:8443";
    };

    provisioner = lib.mkOption {
      type = lib.types.str;
      description = "Name of the provisioner to use";
      default = "admin";
    };

    provisioner-password-file = lib.mkOption {
      type = lib.types.str;
      description = "Path to the file containing the provisioner password";
      example = "/run/secrets/step-ca/password";
    };

    certificates = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          domain = lib.mkOption {
            type = lib.types.str;
            description = "Domain name for the certificate";
            example = "*.example.com";
          };

          cert-dir = lib.mkOption {
            type = lib.types.str;
            description = "Directory to store certificates";
            default = "step-ca/certs";
          };

          notify-service = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            description = "Service to notify after certificate renewal";
            default = null;
          };

          validity-period = lib.mkOption {
            type = lib.types.int;
            description = "Certificate validity period in hours";
            default = 2160; # 90 days
          };
        };
      });
      default = {};
      description = "Attribute set of certificates to maintain";
    };

    renewal-interval = lib.mkOption {
      type = lib.types.str;
      description = "How often to check and renew certificates";
      default = "0 */12 * * *"; # Twice daily
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.step-certificates = {
      description = "Generate and maintain Step CA certificates";
      wantedBy = ["multi-user.target"];
      after = ["network-online.target" "step-ca-bootstrap.service"];
      wants = ["network-online.target"];

      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Group = "root";
        RemainAfterExit = true;
        # Ensure password file exists before starting
        AssertPathExists = [ cfg.provisioner-password-file ];
      };

      path = with pkgs; [step-cli];

      script = let
        # Generate script for each certificate
        generateCert = name: cert: ''
          echo "Processing certificate for ${cert.domain}"

          install -d -m 755 /var/lib/${cert.cert-dir}

          step ca certificate \
            "${cert.domain}" \
            "/var/lib/${cert.cert-dir}/${lib.strings.sanitizeDerivationName name}.crt.new" \
            "/var/lib/${cert.cert-dir}/${lib.strings.sanitizeDerivationName name}.key.new" \
            --ca-url ${cfg.ca-url} \
            --provisioner ${cfg.provisioner} \
            --provisioner-password-file ${cfg.provisioner-password-file} \
            --force \
            --not-after ${toString cert.validity-period}h

          chmod 644 "/var/lib/${cert.cert-dir}/${lib.strings.sanitizeDerivationName name}.crt.new"
          chmod 600 "/var/lib/${cert.cert-dir}/${lib.strings.sanitizeDerivationName name}.key.new"

          mv -f "/var/lib/${cert.cert-dir}/${lib.strings.sanitizeDerivationName name}.crt.new" \
                "/var/lib/${cert.cert-dir}/${lib.strings.sanitizeDerivationName name}.crt"
          mv -f "/var/lib/${cert.cert-dir}/${lib.strings.sanitizeDerivationName name}.key.new" \
                "/var/lib/${cert.cert-dir}/${lib.strings.sanitizeDerivationName name}.key"

          ${lib.optionalString (cert.notify-service != null) ''
            if systemctl is-active --quiet ${cert.notify-service}; then
              systemctl reload ${cert.notify-service} || true
            fi
          ''}
        '';
      in ''
        ${lib.concatStrings (lib.mapAttrsToList generateCert cfg.certificates)}
      '';

      startAt = cfg.renewal-interval;
    };

    # Create tmpfiles rules for all certificates
    systemd.tmpfiles.rules = lib.flatten (
      lib.mapAttrsToList
      (name: cert: [
        "R /var/lib/${cert.cert-dir}/${lib.strings.sanitizeDerivationName name}.crt - - - - -"
        "R /var/lib/${cert.cert-dir}/${lib.strings.sanitizeDerivationName name}.key - - - - -"
        "R /var/lib/${cert.cert-dir}/${lib.strings.sanitizeDerivationName name}.crt.new - - - - -"
        "R /var/lib/${cert.cert-dir}/${lib.strings.sanitizeDerivationName name}.key.new - - - - -"
        "d /var/lib/${cert.cert-dir} 0755 root root -"
      ])
      cfg.certificates
    );
  };
}

