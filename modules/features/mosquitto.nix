{...}: {
  flake.nixosModules.mosquitto = {
    hostname,
    config,
    ...
  }: {
    sops.secrets.homeassistant-password = {
      sopsFile = ../../secrets/${hostname}/mosquitto.yaml;
      format = "yaml";
      key = "users/homeassistant/password";
    };

    networking.firewall.allowedTCPPorts = [1883];

    services.mosquitto = {
      enable = true;

      listeners = [
        {
          port = 1883;
          address = "0.0.0.0";
          settings = {
            protocol = "mqtt";
          };
          users.homeassistant.passwordFile = config.sops.secrets.homeassistant-password.path;
        }
      ];
    };
  };
}
