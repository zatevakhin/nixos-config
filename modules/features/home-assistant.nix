{...}: {
  flake.nixosModules.home-assistant = {
    hostname,
    config,
    lib,
    ...
  }: let
    TLD = "homeworld.lan";
    SERVICE = "ha";
  in {
    services.adguardhome.settings.filtering.rewrites = lib.mkIf config.services.adguardhome.enable [
      {
        domain = "${SERVICE}.${TLD}";
        answer = "${hostname}.lan";
        enabled = true;
      }
      {
        domain = "${SERVICE}-${hostname}.${TLD}";
        answer = "${hostname}.lan";
        enabled = true;
      }
    ];

    services.traefik.dynamicConfigOptions.http.services = lib.mkIf config.services.traefik.enable {
      home-assistant.loadBalancer.servers = [
        {
          url = "http://127.0.0.1:${builtins.toString config.services.home-assistant.config.http.server_port}";
        }
      ];
    };

    services.traefik.dynamicConfigOptions.http.routers = lib.mkIf config.services.traefik.enable {
      home-assistant = {
        rule = "Host(`${SERVICE}.${TLD}`)";
        service = "home-assistant";
        entryPoints = ["websecure"];
        tls.certResolver = "stepca";
      };

      "home-assistant-${hostname}" = {
        rule = "Host(`${SERVICE}-${hostname}.${TLD}`)";
        service = "home-assistant";
        entryPoints = ["websecure"];
        tls.certResolver = "stepca";
      };
    };

    services.home-assistant = {
      enable = true;
      openFirewall = false;
      configDir = "/storage/.services/hass";

      extraComponents = [
        "local_todo"
        "esphome"
        "met"
        "mobile_app"
        "mqtt"
        "jellyfin"
        "wled"
        "zha"
        "cast"
        "adguard"
      ];

      extraPackages = python3Packages:
        with python3Packages; [
          gtts
          getmac
        ];

      config = {
        homeassistant = {
          name = "Home";
          time_zone = "Europe/Lisbon";
          temperature_unit = "C";
          unit_system = "metric";
        };

        logger = {
          default = "info";
        };
        logbook = {};
        backup = {};
        bluetooth = {};
        config = {};
        counter = {};
        dhcp = {};
        energy = {};
        hardware = {};
        history = {};
        homeassistant_alerts = {};
        image_upload = {};
        input_boolean = {};
        input_button = {};
        input_datetime = {};
        input_number = {};
        input_select = {};
        input_text = {};
        media_source = {};
        mobile_app = {};
        network = {};
        person = {};
        schedule = {};
        ssdp = {};
        stream = {};
        sun = {};
        system_health = {};
        system_log = {};
        shopping_list = {};
        tag = {};
        timer = {};
        usb = {};
        webhook = {};
        zeroconf = {};
        frontend = {};

        http = {
          server_port = 8123;
          use_x_forwarded_for = true;
          ip_ban_enabled = true;
          login_attempts_threshold = 5;
          trusted_proxies = [
            "127.0.0.1"
            "::1"
          ];
        };
      };
    };
  };
}
