{
  config,
  hostname,
  ...
}: let
  domain = "minio.homeworld.lan";
in {
  services.adguardhome.settings.filtering.rewrites = [
    {
      domain = domain;
      answer = "${hostname}.lan";
    }
    {
      domain = "console-${domain}";
      answer = "${hostname}.lan";
    }
  ];

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
    listenAddress = "127.0.0.1:9000";
    consoleAddress = "127.0.0.1:9001";
    region = "eu-west-1";
    rootCredentialsFile = config.sops.templates."minio.env".path;
    dataDir = ["/storage/.services/minio/data"];
    configDir = "/storage/.services/minio/config";
    certificatesDir = "/storage/.services/minio/certs";
    browser = true;
  };

  systemd.services.minio.environment = {
    MINIO_DOMAIN = domain;
    MINIO_SERVER_URL = "https://${domain}";
    MINIO_BROWSER_REDIRECT_URL = "https://console-${domain}";
  };
}
