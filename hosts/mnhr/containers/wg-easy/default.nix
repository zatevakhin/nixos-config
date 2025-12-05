{
  pkgs,
  hostname,
  ...
}: let
  domain = "wg.homeworld.lan";
  lan_interface = "enP4p65s0";
  wg_easy_interface = "br-wg-easy";
in {
  services.adguardhome.settings.filtering.rewrites = [
    {
      domain = domain;
      answer = "${hostname}.lan";
    }
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };

  boot.kernelModules = [
    "iptable_nat"
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

    # Extra iptables commands executed when the firewall is (re)loaded
    extraCommands = ''
      ${pkgs.iptables}/bin/iptables -F DOCKER-USER || true
      ${pkgs.iptables}/bin/iptables -I DOCKER-USER 1 -i ${lan_interface} -o ${wg_easy_interface} -j ACCEPT
      ${pkgs.iptables}/bin/iptables -I DOCKER-USER 1 -i ${wg_easy_interface} -o ${lan_interface} -j ACCEPT
    '';

    # Optional: clean up on firewall stop
    extraStopCommands = ''
      ${pkgs.iptables}/bin/iptables -F DOCKER-USER || true
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
}
