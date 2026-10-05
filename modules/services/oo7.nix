# oo7 Secret Service (org.freedesktop.secrets) for headless secret storage.
#
# Provides the freedesktop Secret Service D-Bus API that System3 expects
# (keyring_core + dbus-secret-service backend). Runs as a per-user daemon,
# unlocked non-interactively via a systemd credential — no interactive
# prompt, suitable for a headless coordinator.
#
# The keyring encryption password is supplied as a systemd credential named
# `oo7.keyring-encryption-password`, loaded from a file via LoadCredential so a
# secrets manager (sops-nix/agenix) can own it. The daemon fails closed
# (locked) if the file is missing.
#
# Unlock model (oo7-server 0.6.0 — verified empirically on nano):
#   * The systemd credential auto-unlocks the *persistent default keyring* on
#     startup — but ONLY once that keyring file already exists on disk.
#   * On a virgin machine no keyring file exists, so the daemon creates the
#     default collection *locked* and every store/lookup that omits the secret
#     BLOCKS indefinitely (this was the source of the earlier hangs; neither
#     `--login`-on-stdin nor pam_oo7 fixes it headlessly).
#   * First-run provisioning is therefore required: a single write that supplies
#     the secret inline (`oo7-cli -s <pw>`) creates and encrypts
#     `~/.local/share/keyrings/default.keyring` with the credential password.
#     From then on the credential unlocks it automatically at every start and
#     plain (no-secret) secret-service calls succeed.
#
# `ExecStartPost` below performs that one-time seed idempotently, leaving the
# service immediately usable by System3 with no client-side secret handling.
{...}: {
  flake.nixosModules.oo7 = {
    config,
    lib,
    pkgs,
    username,
    ...
  }: let
    cfg = config.services.oo7Secrets;
    # Path to the file holding the keyring encryption password. Point this at a
    # sops/agenix-decrypted path (e.g. /run/secrets/oo7-keyring-password) once a
    # secrets manager is wired in.
    passwordFile = cfg.passwordFile;

    # One-time keyring provisioning. Runs after the daemon is up; if the default
    # keyring file does not yet exist, it seeds a marker item while supplying the
    # secret inline, which creates+encrypts the persistent default keyring with
    # the credential password. Idempotent: a no-op once the file exists.
    provisionScript = pkgs.writeShellScript "oo7-provision" ''
      set -euo pipefail
      keyring="$HOME/.local/share/keyrings/default.keyring"
      if [ -f "$keyring" ]; then
        exit 0
      fi
      pw="$(cat "$CREDENTIALS_DIRECTORY/oo7.keyring-encryption-password")"
      # Retry briefly: the D-Bus name may take a moment to register after start.
      for i in 1 2 3 4 5; do
        if printf '%s' system3-secret-service-initialised \
          | ${pkgs.oo7}/bin/oo7-cli -s "$pw" store \
              "system3-init" system3=keyring-marker >/dev/null 2>&1; then
          exit 0
        fi
        sleep 1
      done
      echo "oo7 provisioning failed: could not seed default keyring" >&2
      exit 1
    '';
  in {
    options.services.oo7Secrets = {
      enable = lib.mkEnableOption "oo7 Secret Service (org.freedesktop.secrets)";

      passwordFile = lib.mkOption {
        type = lib.types.path;
        default = "/var/lib/oo7/keyring-password";
        description = ''
          File containing the keyring encryption password, fed to the daemon as
          a systemd credential. Replace with a secrets-manager-decrypted path.
        '';
      };
    };

    config = lib.mkIf cfg.enable {
      # oo7-cli for managing entries; oo7-server ships the daemon + D-Bus service.
      environment.systemPackages = [pkgs.oo7 pkgs.oo7-server];

      # Register the D-Bus service so org.freedesktop.secrets activates the daemon.
      services.dbus.packages = [pkgs.oo7-server];

      # Headless user services must survive without an interactive login session.
      users.users.${username}.linger = true;

      # Per-user Secret Service daemon, unlocked via a systemd credential loaded
      # from the password file. Fails closed (locked) when the file is absent.
      systemd.user.services.oo7-daemon = {
        description = "Secret service (oo7 implementation)";
        wantedBy = ["default.target"];
        serviceConfig = {
          Type = "simple";
          # Plain daemon start. The loaded credential unlocks the persistent
          # default keyring on startup once it exists (provisioned below). No
          # `--login`/stdin dance is needed and it does not work headlessly.
          ExecStart = "${pkgs.oo7-server}/libexec/oo7-daemon";
          # First-run keyring provisioning (idempotent). Needs the credential, so
          # it must run within the unit's credential scope. Failure here does not
          # kill the daemon — remaining=none keeps it advisory.
          ExecStartPost = "-${provisionScript}";
          Restart = "on-failure";
          TimeoutStartSec = "30s";
          TimeoutStopSec = "30s";
          LoadCredential = ["oo7.keyring-encryption-password:${passwordFile}"];
          # Hardening (mirrors upstream unit).
          NoNewPrivileges = true;
          ProtectSystem = "full";
          PrivateTmp = true;
          PrivateDevices = true;
          PrivateNetwork = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectControlGroups = true;
          MemoryDenyWriteExecute = true;
          ProtectClock = true;
        };
      };

      # Ensure the password file's parent dir exists (owned by the user).
      systemd.tmpfiles.rules = [
        "d /var/lib/oo7 0700 ${username} users - -"
      ];
    };
  };
}
