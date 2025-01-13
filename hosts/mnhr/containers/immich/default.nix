{pkgs, ...}: {
  systemd.services.immich-compose = {
    environment = {
      IMMICH_VERSION = "release";
      IMMICH_HOST = "0.0.0.0";
      DB_PASSWORD = "postgres";
      TZ = "Europe/Lisbon";

      UPLOAD_LOCATION = "/mnt/storage/.services/immich/data";
      DB_DATA_LOCATION = "/mnt/storage/.services/immich/db";

      DB_USERNAME = "postgres";
      DB_DATABASE_NAME = "immich";
    };

    script = "${pkgs.docker-compose}/bin/docker-compose -f ${./docker-compose.yml} up";

    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "traefik.service"];
  };
}
