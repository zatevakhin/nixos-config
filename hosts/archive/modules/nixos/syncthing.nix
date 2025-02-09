{
  config,
  username,
  ...
}: let
  cfg = import ../../secrets/syncthing.nix;
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
      dataDir = "/mnt/storage/syncthing/";
      configDir = "/mnt/storage/syncthing/.config/";
      guiAddress = "0.0.0.0:8384";
      extraFlags = [
        "--no-default-folder"
      ];

      overrideDevices = true;
      overrideFolders = true;

      settings = {
        gui = {
          theme = "black";
          user = cfg.gui.user;
          password = cfg.gui.password;
        };

        options = {
          crashReportingEnabled = false;
        };

        devices = {
          "baseship.lan" = {id = cfg.devices.baseship.id;};
          "ivan-nothing.phone" = {id = cfg.devices.nothing.id;};
          "anzh-tuxedo.lan" = {id = cfg.devices.tuxedo.id;};
          "anzh-pixel8.phone" = {id = cfg.devices.pixel8.id;};
        };

        folders = {
          "Ivan's Obsidian" = {
            id = cfg.folders.ivan.obsidian.id;
            path = "/mnt/storage/syncthing/ivan/obsidian/";
            devices = ["baseship.lan"];
          };

          "Ivan's Private" = {
            id = cfg.folders.ivan.private.id;
            path = "/mnt/storage/syncthing/ivan/private/";
            devices = ["baseship.lan" "ivan-nothing.phone"];
          };

          "Ivan's Books" = {
            id = cfg.folders.ivan.books.id;
            path = "/mnt/storage/syncthing/ivan/books/";
            devices = ["baseship.lan" "ivan-nothing.phone"];
          };

          "Anzh's Obsidian" = {
            id = cfg.folders.anzh.obsidian.id;
            path = "/mnt/storage/syncthing/anzh/obsidian/";
            devices = ["anzh-tuxedo.lan"];
          };

          "Anzh's Passwords" = {
            id = cfg.folders.anzh.passwords.id;
            path = "/mnt/storage/syncthing/anzh/passwords/";
            devices = ["anzh-pixel8.phone" "anzh-tuxedo.lan"];
          };
        };
      };
    };
  };
}
