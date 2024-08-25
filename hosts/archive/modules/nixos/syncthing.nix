{username, ...}: let
  cfg = import ../../secrets/syncthing.nix;
in {
  services = {
    syncthing = {
      enable = true;
      cert = "/mnt/storage/syncthing/.config/creds/cert.pem";
      user = username;
      key = "/mnt/storage/syncthing/.config/creds/key.pem";
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

        devices = {
          "baseship.lan" = {id = cfg.devices.baseship.id;};
          "ivan-nothing.phone" = {id = cfg.devices.nothing.id;};
          "anzh-samsung.phone" = {id = cfg.devices.s21u.id;};
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
            devices = ["anzh-samsung.phone" "anzh-pixel8.phone" "anzh-tuxedo.lan"];
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
