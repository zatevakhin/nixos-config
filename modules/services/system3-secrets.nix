{...}: {
  flake.nixosModules.system3-secrets = {
    config,
    lib,
    pkgs,
    ...
  }: let
    cfg = config.services.system3.sopsSecrets;
    runtime = config.services.system3.userService;
    user = runtime.user;
    uid = config.users.users.${user}.uid;
    restartUnit = "system3-secrets-refresh";
    secretId = name: "system3/${name}";
    secretPath = name: config.sops.secrets.${secretId name}.path;
    names = builtins.attrNames cfg.secrets;
    validName = name:
      builtins.stringLength name
      <= 128
      && builtins.match "[A-Za-z0-9][A-Za-z0-9._/-]*" name != null
      && !lib.hasSuffix "/" name
      && !(builtins.elem ".." (lib.splitString "/" name));
    provision = pkgs.writeShellScript "system3-secrets-import" ''
      set -euo pipefail
      export PATH=${lib.makeBinPath [pkgs.coreutils pkgs.gnugrep pkgs.systemd]}
      if [ "$(busctl --user get-property org.freedesktop.secrets \
        /org/freedesktop/secrets/collection/Default org.freedesktop.Secret.Collection Locked)" != "b false" ]; then
        echo "System3 credential import requires an unlocked oo7 keyring" >&2
        exit 1
      fi

      # Validate every input before changing any keyring entry. Never log values.
      ${lib.concatMapStringsSep "\n" (name: ''
          file=${lib.escapeShellArg (secretPath name)}
          if [ ! -f "$file" ] || [ ! -r "$file" ] || [ ! -s "$file" ] \
            || ! grep -q '[^[:space:]]' "$file" \
            || grep -qF 'REPLACE_ME_' "$file"; then
            echo ${lib.escapeShellArg "Missing, empty, or placeholder SOPS credential: ${name}"} >&2
            exit 1
          fi
        '')
        names}

      ${lib.concatMapStringsSep "\n" (name: ''
          ${lib.getExe runtime.package} secrets set --stdin ${lib.escapeShellArg name} < ${lib.escapeShellArg (secretPath name)}
        '')
        names}
    '';
  in {
    options.services.system3.sopsSecrets = {
      enable = lib.mkEnableOption "provisioning System3's user keyring from sops-nix";
      sopsFile = lib.mkOption {
        type = lib.types.path;
        description = "Encrypted SOPS YAML file; plaintext is consumed only at runtime.";
      };
      secrets = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        description = ''
          Map System3 secret names (without secret://) to YAML key paths.
          Managed entries are overwritten on startup; removing an entry from this
          map does not delete its existing keyring value.
        '';
      };
    };

    config = lib.mkIf cfg.enable {
      assertions = [
        {
          assertion = runtime.enable && user != null && config.services.oo7Secrets.enable;
          message = "System3 SOPS provisioning requires its user service and oo7.";
        }
        {
          assertion = uid != null;
          message = "System3 SOPS provisioning requires a fixed UID for the service user.";
        }
        {
          assertion = names != [] && builtins.all validName names;
          message = "System3 SOPS provisioning requires nonempty, valid System3 secret names.";
        }
      ];

      sops.secrets = lib.mapAttrs' (name: key:
        lib.nameValuePair (secretId name) {
          inherit key;
          sopsFile = cfg.sopsFile;
          format = "yaml";
          owner = user;
          mode = "0400";
          restartUnits = ["${restartUnit}.service"];
        })
      cfg.secrets;

      systemd.user.services.${runtime.serviceName} = {
        requires = ["oo7-daemon.service"];
        after = ["oo7-daemon.service"];
        # This runs as the user, before upstream's keyring check and pipeline load.
        serviceConfig.ExecStartPre = lib.mkBefore ["${provision}"];
      };

      # sops-nix restarts system units, not user units. Keep a bridge active so
      # try-restart on rotation reaches the user's service and reimports keys.
      systemd.services.${restartUnit} = {
        description = "Refresh System3 user credentials after SOPS changes";
        wantedBy = ["multi-user.target"];
        requires = ["user@${toString uid}.service"];
        after = ["sops-install-secrets.service" "user@${toString uid}.service"];
        restartTriggers = [cfg.sopsFile provision];
        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          ExecStart = "${pkgs.systemd}/bin/systemctl --user --machine=${user}@.host restart ${runtime.serviceName}.service";
          TimeoutStartSec = "120s";
        };
      };
    };
  };
}
