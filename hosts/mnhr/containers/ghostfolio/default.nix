{
  pkgs,
  config,
  ...
}: {
  sops.secrets.redis_password = {
    sopsFile = ../../secrets/ghostfolio.yaml;
    format = "yaml";
    key = "redis/password";
  };

  sops.secrets.pg_password = {
    sopsFile = ../../secrets/ghostfolio.yaml;
    format = "yaml";
    key = "postgresql/password";
  };

  sops.secrets.gf_access_token_salt = {
    sopsFile = ../../secrets/ghostfolio.yaml;
    format = "yaml";
    key = "ghostfolio/access_token_salt";
  };

  sops.secrets.gf_jwt_secret_key = {
    sopsFile = ../../secrets/ghostfolio.yaml;
    format = "yaml";
    key = "ghostfolio/jwt_secret_key";
  };

  sops.templates."ghostfolio.env".content = ''
    REDIS_PASSWORD="${config.sops.placeholder.redis_password}"
    POSTGRES_DB="ghostfolio-db"
    POSTGRES_USER="user"
    POSTGRES_PASSWORD="${config.sops.placeholder.pg_password}"
    ACCESS_TOKEN_SALT="${config.sops.placeholder.gf_access_token_salt}"
    JWT_SECRET_KEY="${config.sops.placeholder.gf_jwt_secret_key}"
  '';

  systemd.services.ghostfolio-compose = {
    environment = {
      COMPOSE_PROJECT_NAME = "ghostfolio";
      REDIS_HOST = "localhost";
      REDIS_PORT = "6379";
    };

    serviceConfig = {
      EnvironmentFile = config.sops.templates."ghostfolio.env".path;
    };

    script = "${pkgs.docker-compose}/bin/docker-compose -f ${./docker-compose.yml} up";
    wantedBy = ["multi-user.target"];
    after = ["docker.service" "docker.socket" "traefik-compose.service"];
  };
}
