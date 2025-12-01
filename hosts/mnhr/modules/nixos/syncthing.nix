{
  config,
  username,
  ...
}: let
  syncthing = import ../../secrets/syncthing.nix;
in {
  sops.secrets.syncthing_private_key = {
    sopsFile = ../../secrets/syncthing.yaml;
    format = "yaml";
    key = "syncthing/keys/private";
    owner = username;
  };

  sops.secrets.syncthing_public_key = {
    sopsFile = ../../secrets/syncthing.yaml;
    format = "yaml";
    key = "syncthing/keys/public";
    owner = username;
  };

  # NOTE: GUI port is not in the list of default ports.
  networking.firewall.allowedTCPPorts = [8384];

  services = {
    syncthing = {
      enable = true;
      openDefaultPorts = true;
      cert = config.sops.secrets.syncthing_public_key.path;
      key = config.sops.secrets.syncthing_private_key.path;
      user = username;
      dataDir = "/storage/syncthing/";
      guiAddress = "0.0.0.0:8384";
      extraFlags = [];

      overrideDevices = true;
      overrideFolders = true;

      settings = {
        gui = {
          theme = "black";
          user = syncthing.gui.user;
          password = syncthing.gui.password;
        };

        options = {
          urAccepted = -1;
          crashReportingEnabled = false;
        };

        devices = syncthing.devices;

        folders = {
          "${syncthing.folders.ivan.obsidian.id}" = {
            label = "Ivan's Obsidian";
            devices = [syncthing.device.arar syncthing.device.baseship syncthing.device.lstr];
            path = "/storage/syncthing/ivan/obsidian/";
            versioning = {
              type = "trashcan";
              params.cleanoutDays = "1000";
            };
          };

          "${syncthing.folders.ivan.private.id}" = {
            label = "Ivan's Private";
            devices = [syncthing.device.arar syncthing.device.baseship syncthing.device.lstr syncthing.device.nothing];
            path = "/storage/syncthing/ivan/private/";
            versioning = {
              type = "trashcan";
              params.cleanoutDays = "1000";
            };
          };

          "${syncthing.folders.ivan.books.id}" = {
            label = "Ivan's Books";
            devices = [syncthing.device.arar syncthing.device.baseship syncthing.device.lstr syncthing.device.nothing];
            path = "/storage/syncthing/ivan/books/";
          };

          "${syncthing.folders.anzh.obsidian.id}" = {
            label = "Anzh's Obsidian";
            devices = [syncthing.device.arar syncthing.device.tuxedo];
            path = "/storage/syncthing/anzh/obsidian/";
            versioning = {
              type = "trashcan";
              params.cleanoutDays = "1000";
            };
          };

          "${syncthing.folders.anzh.passwords.id}" = {
            label = "Anzh's Passwords";
            devices = [syncthing.device.arar syncthing.device.pixel8 syncthing.device.tuxedo];
            path = "/storage/syncthing/anzh/passwords/";
            versioning = {
              type = "trashcan";
              params.cleanoutDays = "1000";
            };
          };
        };
      };
    };
  };
}
