{username, ...}: let
  cfg = import ../../secrets/syncthing.nix;
in {
  services = {
    syncthing = {
      enable = true;
      cert = "/home/${username}/.config/creds/syncthing/cert.pem";
      key = "/home/${username}/.config/creds/syncthing/key.pem";
      user = username;
      dataDir = "/home/${username}/Documents";
      configDir = "/home/${username}/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        gui = {
          user = cfg.gui.user;
          password = cfg.gui.password;
        };

        devices = {
          "archive.lan" = {id = cfg.devices.archive.id;};
        };

        folders = {
          "Ivan's Obsidian" = {
            id = cfg.folders.obsidian.id;
            path = "/home/${username}/Documents/Obsidian";
            devices = ["archive.lan"];
          };

          "Ivan's Private" = {
            id = cfg.folders.private.id;
            path = "/home/${username}/Documents/Private";
            devices = ["archive.lan"];
          };

          "Ivan's Books" = {
            id = cfg.folders.books.id;
            path = "/home/${username}/Documents/Books";
            devices = ["archive.lan"];
          };
        };
      };
    };
  };
}
