{
  pkgs,
  config,
  ...
}: {
  sops.secrets.telegraf_influx_token = {
    sopsFile = ../../secrets/telegraf.yaml;
    format = "yaml";
    key = "influx/token";
  };

  sops.templates."telegraf.env".content = ''
    INFLUXDB_TOKEN=${config.sops.placeholder.telegraf_influx_token}
  '';

  services.telegraf.environmentFiles = [
    config.sops.templates."telegraf.env".path
  ];

  systemd.services.telegraf.path = with pkgs; [
    smartmontools
    lm_sensors
  ];

  users.users.telegraf = {
    isSystemUser = true;
    extraGroups = ["docker"];
  };

  services.telegraf = {
    enable = true;
    extraConfig = {
      inputs = {
        cpu = {
          percpu = true;
          totalcpu = true;
        };
        disk = {
          ignore_fs = ["tmpfs" "devtmpfs"];
        };
        diskio = {};
        system = {};
        swap = {};
        smart = {};
        sensors = {};
        docker = {};
        mem = {};
        net = {
          interfaces = ["eth*" "en*"];
        };
        docker = {
          endpoint = "unix:///var/run/docker.sock";
          container_state_include = ["created" "restarting" "running" "removing" "paused" "exited" "dead"];
        };
      };

      outputs = {
        influxdb_v2 = {
          organization = "HomeWorld";
          bucket = "default";
          token = "$INFLUXDB_TOKEN";
          urls = [
            "https://influxdb.homeworld.lan"
          ];
        };
      };
    };
  };
}
