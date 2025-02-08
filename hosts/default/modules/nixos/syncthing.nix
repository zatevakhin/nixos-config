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

  services = {
    syncthing = {
      enable = true;
      cert = config.sops.secrets.syncthing_public_key.path;
      key = config.sops.secrets.syncthing_private_key.path;
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
