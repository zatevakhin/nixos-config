{config, ...}: {
  sops.secrets.minio-user = {
    sopsFile = ../../secrets/minio.yaml;
    format = "yaml";
    key = "minio/user";
    owner = config.systemd.services.minio.serviceConfig.User;
  };

  sops.secrets.minio-password = {
    sopsFile = ../../secrets/minio.yaml;
    format = "yaml";
    key = "minio/password";
    owner = config.systemd.services.minio.serviceConfig.User;
  };

  sops.templates."minio.env" = {
    content = ''
      MINIO_ROOT_USER=${config.sops.placeholder.minio-user}
      MINIO_ROOT_PASSWORD='${config.sops.placeholder.minio-password}'
    '';
    owner = config.systemd.services.minio.serviceConfig.User;
  };

  services.minio = {
    enable = true;
    region = "eu-west-1";
    rootCredentialsFile = config.sops.templates."minio.env".path;
    dataDir = ["/storage/.services/minio/data"];
    configDir = "/storage/.services/minio/config";
    certificatesDir = "/storage/.services/minio/certs";
    browser = true;
  };

  systemd.services.minio.environment = let
    domain = "minio.homeworld.lan";
  in {
    MINIO_DOMAIN = domain;
    MINIO_SERVER_URL = "https://${domain}";
    MINIO_BROWSER_REDIRECT_URL = "https://console-${domain}";
  };
}
