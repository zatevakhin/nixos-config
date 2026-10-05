{...}: {
  flake.nixosModules.arar-syncthing = {
    config,
    username,
    hostname,
    inputs,
    lib,
    ...
  }: let
    st = lib.importTOML "${inputs.notsecrets}/syncthing.toml";

    shares = {
      private = {
        devices = ["mnhr" "lstr" "nothing"];
        path = "/mnt/storage/syncthing/ivan/private/";
        versioning = {
          type = "trashcan";
          params.cleanoutDays = "1000";
        };
      };

      obsidian = {
        devices = ["mnhr" "lstr"];
        path = "/mnt/storage/syncthing/ivan/obsidian/";
        versioning = {
          type = "trashcan";
          params.cleanoutDays = "1000";
        };
      };

      books = {
        devices = ["mnhr" "lstr" "nothing"];
        path = "/mnt/storage/syncthing/ivan/books/";
      };

      anzh-obsidian = {
        devices = ["mnhr" "framework"];
        path = "/mnt/storage/syncthing/anzh/obsidian/";
        versioning = {
          type = "trashcan";
          params.cleanoutDays = "1000";
        };
      };

      anzh-passwords = {
        devices = ["mnhr" "framework"];
        path = "/mnt/storage/syncthing/anzh/passwords/";
        versioning = {
          type = "trashcan";
          params.cleanoutDays = "1000";
        };
      };
    };
  in {
    sops.secrets.syncthing_private_key = {
      sopsFile = ../../../secrets/${hostname}/syncthing.yaml;
      format = "yaml";
      key = "syncthing/keys/private";
      owner = username;
    };

    sops.secrets.syncthing_public_key = {
      sopsFile = ../../../secrets/${hostname}/syncthing.yaml;
      format = "yaml";
      key = "syncthing/keys/public";
      owner = username;
    };

    sops.secrets.syncthing_gui_password = {
      sopsFile = ../../../secrets/${hostname}/syncthing.yaml;
      format = "yaml";
      key = "syncthing/gui/password";
      owner = username;
    };

    # NOTE: GUI port is not in the list of default ports.
    networking.firewall.allowedTCPPorts = [8384];

    services = {
      syncthing = {
        enable = true;
        openDefaultPorts = true;
        guiAddress = "0.0.0.0:8384";
        cert = config.sops.secrets.syncthing_public_key.path;
        key = config.sops.secrets.syncthing_private_key.path;
        user = username;
        dataDir = "/mnt/storage/syncthing/";
        configDir = "/mnt/storage/syncthing/.config/";
        guiPasswordFile = config.sops.secrets.syncthing_gui_password.path;

        overrideDevices = true;
        overrideFolders = true;

        settings = {
          gui = {
            user = "admin";
            theme = "black";
          };

          options = {
            urAccepted = -1;
            crashReportingEnabled = false;
          };

          devices = lib.filterAttrs (name: _: lib.elem name (lib.concatLists (lib.mapAttrsToList (_: s: s.devices) shares))) st.devices;
          folders = lib.mapAttrs (name: s:
            {
              inherit (s) path devices;
              inherit (st.folders.${name}) id label;
            }
            // (removeAttrs s ["path" "devices"]))
          shares;
        };
      };
    };
  };
}
