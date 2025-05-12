{
  pkgs,
  config,
  hostname,
  ...
}: let
  domain = "influxdb.homeworld.lan";

  manage-influx-buckets = pkgs.writeShellScriptBin "manage-influx-buckets" ''
    set -e

    create_bucket_if_missing() {
      local bucket_name=$1
      local retention=$2

      # Check if bucket exists
      if ! ${pkgs.influxdb2-cli}/bin/influx bucket list \
        --org HomeWorld \
        --token "$DOCKER_INFLUXDB_INIT_ADMIN_TOKEN" | grep -q "^$bucket_name"; then

        echo "Creating bucket: $bucket_name"
        ${pkgs.influxdb2-cli}/bin/influx bucket create \
          --name "$bucket_name" \
          --org HomeWorld \
          --retention "$retention" \
          --token "$DOCKER_INFLUXDB_INIT_ADMIN_TOKEN"
      else
        echo "Bucket $bucket_name already exists"
      fi
    }

    echo "Waiting for InfluxDB to be ready..."
    until ${pkgs.curl}/bin/curl -s https://influxdb.homeworld.lan/ping > /dev/null; do
      sleep 1
    done

    # NOTE: Additional buckets go here
    # create_bucket_if_missing "telegraf" "30d"
  '';
in {
  services.adguardhome.settings.filtering.rewrites = [
    {
      domain = domain;
      answer = "${hostname}.lan";
    }
  ];

  sops.secrets.influx_default_password = {
    sopsFile = ../../secrets/influxdb.yaml;
    format = "yaml";
    key = "default/password";
  };

  sops.secrets.influx_default_token = {
    sopsFile = ../../secrets/influxdb.yaml;
    format = "yaml";
    key = "default/token";
  };

  sops.templates."influxdb.env".content = ''
    DOCKER_INFLUXDB_INIT_PASSWORD=${config.sops.placeholder.influx_default_password}
    DOCKER_INFLUXDB_INIT_ADMIN_TOKEN=${config.sops.placeholder.influx_default_token}
  '';

  systemd.services.influxdb-compose = {
    environment = {
      INTERNAL_DOMAIN_NAME = domain;
    };

    serviceConfig = {
      Type = "simple";
      ExecStart = "${pkgs.docker-compose}/bin/docker-compose --file ${./docker-compose.yml} up";
      ExecStop = "${pkgs.docker-compose}/bin/docker-compose --file ${./docker-compose.yml} stop";
      EnvironmentFile = config.sops.templates."influxdb.env".path;
      StandardOutput = "syslog";
      Restart = "on-failure";
      RestartSec = 5;
      StartLimitIntervalSec = 60;
      StartLimitBurst = 3;
    };

    environment = {
      DOCKER_INFLUXDB_INIT_MODE = "setup";
      DOCKER_INFLUXDB_INIT_USERNAME = "admin";
      DOCKER_INFLUXDB_INIT_ORG = "HomeWorld";
      DOCKER_INFLUXDB_INIT_BUCKET = "default";
      DOCKER_INFLUXDB_INIT_RETENTION = "1w";
    };

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "traefik.service"];
  };

  systemd.services.influxdb-buckets = {
    description = "Manage InfluxDB buckets";

    after = ["influxdb-compose.service"];
    requires = ["influxdb-compose.service"];
    wantedBy = ["multi-user.target"];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.bash}/bin/bash ${manage-influx-buckets}/bin/manage-influx-buckets";
      EnvironmentFile = config.sops.templates."influxdb.env".path;
    };
  };
}
