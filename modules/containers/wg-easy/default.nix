{...}: {
  flake.nixosModules.container-wg-easy = {
    lib,
    pkgs,
    hostname,
    ...
  }: let
    domain = "wg.homeworld.lan";
    lan_interface = "enp1s0";
    wg_easy_interface = "br-wg-easy";
  in {
    services.adguardhome.settings.filtering.rewrites = [
      {
        domain = domain;
        answer = "${hostname}.lan";
        enabled = true;
      }
    ];

    boot.kernel.sysctl = {
      "net.ipv4.ip_forward" = 1;
    };

    boot.kernelModules = [
      "wireguard"
      "nf_tables"
      "nft_masq"
    ];

    # Static route: WG network lives behind the container at 10.10.0.2
    networking.interfaces."${wg_easy_interface}".ipv4.routes = [
      {
        address = "10.8.0.0";
        prefixLength = 24;
        via = "10.10.0.2";
      }
    ];

    networking.firewall = {
      enable = true;
      allowedUDPPorts = [51820];

      extraForwardRules = ''
        iifname "${lan_interface}" oifname "${wg_easy_interface}" accept
        iifname "${wg_easy_interface}" oifname "${lan_interface}" accept
        ip saddr 10.8.0.0/24 accept
        ip daddr 10.8.0.0/24 accept
      '';

      extraReversePathFilterRules = ''
        ip saddr 10.8.0.0/24 accept
      '';
    };

    systemd.services.wg-easy-compose = {
      environment = {
        INTERNAL_DOMAIN_NAME = domain;
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.docker-compose}/bin/docker-compose --file ${./docker-compose.yml} up";
        ExecStop = "${pkgs.docker-compose}/bin/docker-compose --file ${./docker-compose.yml} stop";
        StandardOutput = "syslog";
        Restart = "on-failure";
        RestartSec = 5;
        StartLimitIntervalSec = 60;
        StartLimitBurst = 3;
      };

      wantedBy = ["multi-user.target"];
      after = ["docker.service" "docker.socket" "traefik.service"];
    };
  };
}
