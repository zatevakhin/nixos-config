{
  pkgs,
  config,
  ...
}: let
  domain = "step-ca.homeworld.lan";
in {
  # INFO: Usage
  # 1. Verify that certificate is available. Should match with that one in logs of `stpe-ca.service`.
  # >>> sudo nix run nixpkgs#step-cli -- certificate fingerprint /var/lib/step-ca/certs/root_ca.crt
  # 2. Retrieve certificate
  # >>> nix run nixpkgs#step-cli -- ca bootstrap --ca-url https://ca.homeworld.lan:8443 --fingerprint <fingerprint>
  # 3. Retrieve certificate and save it to nix store.
  # ```nix
  # security.pki.certificateFiles = [
  #   (pkgs.fetchurl {
  #     url = "https://<domain>[:port]/roots.pem";
  #     hash = "sha256-+EsQqEb+jaLKq4/TOUTEwF/9lwU5mETu4MY4GTN1V+A=";
  #     curlOpts = "--insecure";
  #   })
  # ];
  # ```
  # 4. Install certificate. Copy certificate content.
  # ```nix
  #   security.pki.certificates = [
  #     ''
  #       -----BEGIN CERTIFICATE-----
  #       (Your certificate content here)
  #       -----END CERTIFICATE-----
  #     ''
  #   ];
  # ```
  # WARN: This part can't be used with `sops-nix`.
  # Or store certificate in file.
  # ```nix
  #   security.pki.certificateFiles = [ </path/to/certificate> ];
  # ```

  sops.secrets.step-ca-password = {
    sopsFile = ../../secrets/step-ca.yaml;
    format = "yaml";
    key = "step/password";
    owner = "step-ca";
  };

  systemd.services.step-ca-init = {
    description = "Initialize Step CA";
    wantedBy = ["multi-user.target" "step-ca.service"];
    after = ["network-online.target"];
    wants = ["network-online.target"];

    environment = {
      STEP_CA_DNS = domain;
      HOME = "%S/step-ca";
      STEPPATH = "%S/step-ca";
    };

    # Ensure the service runs only once
    serviceConfig = {
      User = "step-ca";
      Group = "step-ca";
      StateDirectory = "step-ca";
      UMask = "0077";
      DynamicUser = true;
    };

    path = with pkgs; [
      step-cli
      step-ca
    ];

    script = ''
      # Check if already initialized
      if [ -f $HOME/config/ca.json ]; then
        echo "Step CA already initialized"
        exit 0
      fi

      # Ensure clean
      if [ -d "$HOME" ]; then
        echo "Cleanup @ $HOME"
        rm -rf "$HOME/certs" "$HOME/config" "$HOME/db" "$HOME/secrets" "$HOME/templates"
      fi

      # Initialize Step CA
      step ca init \
        --name="StepSister CA" \
        --dns="$STEP_CA_DNS" \
        --address="${config.services.step-ca.address}:${toString config.services.step-ca.port}" \
        --provisioner="admin" \
        --password-file="${config.sops.secrets.step-ca-password.path}" \
        --provisioner-password-file="${config.sops.secrets.step-ca-password.path}" \
        --acme
    '';

    preStart = ''
      # Ensure password file exist
      if [ ! -f ${config.sops.secrets.step-ca-password.path} ]; then
        echo "CA password file not found at '${config.sops.secrets.step-ca-password.path}'."
        exit 1
      fi
    '';
  };

  services.step-ca = {
    enable = true;
    openFirewall = true;
    port = 8443;
    address = "0.0.0.0";
    intermediatePasswordFile = config.sops.secrets.step-ca-password.path;
    settings = {
      root = "/var/lib/step-ca/certs/root_ca.crt";
      federatedRoots = null;
      crt = "/var/lib/step-ca/certs/intermediate_ca.crt";
      key = "/var/lib/step-ca/secrets/intermediate_ca_key";
      insecureAddress = "";
      dnsNames = [domain];
      logger = {
        format = "text";
      };
      db = {
        type = "badgerv2";
        dataSource = "/var/lib/step-ca/db";
        badgerFileLoadingMode = "FileIO";
      };
      authority = {
        enableAdmin = true;
        certificateAuthority = "https://${domain}:8443";
        certificateAuthorityFingerprint = "295b225084a9a421b5c9190cd3347467bb722b72efb19052bb8dea895081e0db";
        certificateIssuer = {
          type = "jwk";
          provisioner = "acme-jwk";
        };
        claims = {
          minTLSCertDuration = "5m";
          maxTLSCertDuration = "2160h";
          defaultTLSCertDuration = "2160h";
        };
        policy = {
          x509 = {
            allow = {
              dns = ["*.homeworld.lan"];
            };
            allowWildcardNames = true;
          };
        };
        provisioners = [
          {
            type = "ACME";
            name = "acme";
          }
        ];
      };
      tls = {
        cipherSuites = [
          "TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256"
          "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256"
        ];
        minVersion = 1.2;
        maxVersion = 1.3;
        renegotiation = false;
      };
    };
  };
}
