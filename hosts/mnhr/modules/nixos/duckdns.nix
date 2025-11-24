{config, ...}: {
  sops.secrets.duckdns-token = {
    sopsFile = ../../secrets/duckdns.yaml;
    format = "yaml";
    key = "token";
  };

  sops.secrets.duckdns-domains = {
    sopsFile = ../../secrets/duckdns.yaml;
    format = "yaml";
    key = "domains";
  };

  services.duckdns = {
    enable = true;
    tokenFile = config.sops.secrets.duckdns-token.path;
    domainsFile = config.sops.secrets.duckdns-domains.path;
  };
}
