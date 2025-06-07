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
          user = syncthing.gui.user;
          password = syncthing.gui.password;
        };

        options = {
          urAccepted = -1;
          crashReportingEnabled = false;
        };

        devices = syncthing.devices;

        folders = {
          "${syncthing.folders.obsidian.id}" = {
            label = "Ivan's Obsidian";
            id = syncthing.folders.obsidian.id;
            path = "/home/${username}/Documents/Obsidian";
            devices = [syncthing.device.arar syncthing.device.mnhr];
          };

          "${syncthing.folders.private.id}" = {
            label = "Ivan's Private";
            path = "/home/${username}/Documents/Private";
            devices = [syncthing.device.arar syncthing.device.mnhr];
          };

          "${syncthing.folders.books.id}" = {
            label = "Ivan's Books";
            path = "/home/${username}/Documents/Books";
            devices = [syncthing.device.arar syncthing.device.mnhr];
          };
        };
      };
    };
  };
}
