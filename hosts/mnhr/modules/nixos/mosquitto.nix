{config, ...}: {
  sops.secrets.homeassistant-password = {
    sopsFile = ../../secrets/mosquitto.yaml;
    format = "yaml";
    key = "users/homeassistant/password";
  };

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
}
