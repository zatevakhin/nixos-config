{config, ...}: {
  sops.secrets.influx_admin_token = {
    sopsFile = ../../secrets/influxdb.yaml;
    format = "yaml";
    key = "default/token";
    owner = config.systemd.services.grafana.serviceConfig.User;
  };

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "127.0.0.1";
        http_port = 3000;
        enforce_domain = true;
        enable_gzip = true;
        domain = "grafana.homeworld.lan";

        # Alternatively, if you want to server Grafana from a subpath:
        # domain = "your.domain";
        # root_url = "https://your.domain/grafana/";
        # serve_from_sub_path = true;
      };

      # Prevents Grafana from phoning home
      analytics.reporting_enabled = false;
    };
    provision = {
      enable = true;
      datasources.settings = {
        apiVersion = 1;

        deleteDatasources = [
          {
            name = "InfluxDB";
            orgId = 1;
          }
        ];

        datasources = [
          {
            name = "InfluxDB";
            type = "influxdb";
            access = "proxy";
            url = "https://influxdb.homeworld.lan";
            jsonData = {
              version = "Flux";
              organization = "HomeWorld";
              defaultBucket = "default";
              tlsSkipVerify = false;
            };
            secureJsonData = {
              token = "$__file{${config.sops.secrets.influx_admin_token.path}}";
            };
            isDefault = true;
            editable = false;
            version = 1;
            orgId = 1;
          }
        ];
      };
    };
  };
}
