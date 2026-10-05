{...}: {
  flake.nixosModules.lstr-syncthing = {
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
        path = "/home/${username}/Documents/Private";
        devices = ["arar" "mnhr"];
      };

      obsidian = {
        path = "/home/${username}/Documents/Obsidian";
        devices = ["arar" "mnhr"];
      };

      books = {
        path = "/home/${username}/Documents/Books";
        devices = ["arar" "mnhr"];
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

    services = {
      syncthing = {
        enable = true;
        cert = config.sops.secrets.syncthing_public_key.path;
        key = config.sops.secrets.syncthing_private_key.path;
        user = username;
        dataDir = "/home/${username}/Documents";
        configDir = "/home/${username}/.config/syncthing";
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
