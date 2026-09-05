{...}: {
  flake.nixosModules.stump = {
    hostname,
    config,
    inputs,
    pkgs,
    lib,
    ...
  }: let
    TLD = "homeworld.lan";
    SERVICE = "stump";
    domain = "${SERVICE}.${TLD}";
    domainHost = "${SERVICE}-${hostname}.${TLD}";
  in {
    imports = [
      "${inputs.nixpkgs-unstable}/nixos/modules/services/web-apps/stump.nix"
    ];

    assertions = [
      {
        assertion = config.services.adguardhome.enable;
        message = "stump requires services.adguardhome.enable";
      }
      {
        assertion = config.services.traefik.enable;
        message = "stump requires services.traefik.enable";
      }
    ];

    services.adguardhome.settings.filtering.rewrites = [
      {
        inherit domain;
        answer = "${hostname}.lan";
        enabled = true;
      }
      {
        domain = domainHost;
        answer = "${hostname}.lan";
        enabled = true;
      }
    ];

    services.stump = {
      enable = true;
      package = inputs.nixpkgs-unstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}.stump;
      openFirewall = false;
      configLocation = "/storage/.services/stump/config";
      environment = {
        STUMP_TRUST_PROXY_HEADERS = "true";
        FORCE_DB_RESET = "false";
      };
    };

    systemd.services.stump = {
      after = ["traefik.service"];
    };

    systemd.tmpfiles.rules = [
      "d ${config.services.stump.configLocation} 0750 ${config.services.stump.user} ${config.services.stump.group} -"
      "d /storage/.services/stump/data 0750 ${config.services.stump.user} ${config.services.stump.group} -"
    ];
    systemd.services.stump.serviceConfig.ReadWritePaths = [
      "/storage/.services/stump/config"
      "/storage/.services/stump/data"
    ];

    services.traefik.dynamicConfigOptions.http = {
      routers.stump = {
        rule = "Host(`${domain}`) || Host(`${domainHost}`)";
        service = "stump";
        entryPoints = ["websecure"];
        tls.certResolver = "stepca";
      };
      services.stump.loadBalancer.servers = [
        {url = "http://127.0.0.1:${toString config.services.stump.port}";}
      ];
    };
  };
}
