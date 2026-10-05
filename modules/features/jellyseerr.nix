{...}: {
  flake.nixosModules.jellyseerr = {
    hostname,
    config,
    lib,
    ...
  }: let
    TLD = "homeworld.lan";
    SERVICE = "jellyseerr";
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
      jellyseerr.loadBalancer.servers = [
        {
          url = "http://localhost:${builtins.toString config.services.jellyseerr.port}";
        }
      ];
    };

    services.traefik.dynamicConfigOptions.http.routers = lib.mkIf config.services.traefik.enable {
      jellyseerr = {
        rule = "Host(`${SERVICE}.${TLD}`)";
        service = "jellyseerr";
        entryPoints = ["websecure"];
        tls.certResolver = "stepca";
      };

      "jellyseerr-${hostname}" = {
        rule = "Host(`${SERVICE}-${hostname}.${TLD}`)";
        service = "jellyseerr";
        entryPoints = ["websecure"];
        tls.certResolver = "stepca";
      };
    };

    services.seerr = {
      enable = true;
      openFirewall = false;
    };
  };
}
