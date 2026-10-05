{...}: {
  flake.nixosModules.stcr-wireguard = {
    hostname,
    config,
    lib,
    ...
  }: let
    inherit (lib) concatStringsSep optionalString;

    # notsecrets has no personal/stcr.toml yet; public facts stay as they were
    # in the old host module. Secret material comes from secrets/stcr/wg.yaml.
    home = {
      machine.ip = "10.8.0.3/32";
      peer = {
        dns = "192.168.1.100";
        search = [];
        allowed_ips = ["10.8.0.3/32" "192.168.1.0/24"];
      };
    };

    sopsFile = ../../../secrets/${hostname}/wg.yaml;

    dnsLine = servers: search: let
      all = servers ++ search;
    in
      optionalString (all != []) "DNS = ${concatStringsSep ", " all}";

    homeConf = ''
      [Interface]
      Address = ${home.machine.ip}
      PrivateKey = ${config.sops.placeholder."wg/home/private_key"}
      ListenPort = 51820
      ${dnsLine [home.peer.dns] home.peer.search}

      [Peer]
      PublicKey = ${config.sops.placeholder."wg/home/public_key"}
      PresharedKey = ${config.sops.placeholder."wg/home/preshared_key"}
      AllowedIPs = ${concatStringsSep ", " home.peer.allowed_ips}
      Endpoint = ${config.sops.placeholder."wg/home/endpoint"}
      PersistentKeepalive = 25
    '';

    templates = {
      "home.conf" = {
        content = homeConf;
        mode = "0400";
        restartUnits = ["wg-quick-home.service"];
      };
    };
  in {
    sops.secrets."wg/home/private_key" = {
      inherit sopsFile;
      key = "home/private_key";
    };
    sops.secrets."wg/home/preshared_key" = {
      inherit sopsFile;
      key = "home/preshared_key";
    };
    sops.secrets."wg/home/public_key" = {
      inherit sopsFile;
      key = "home/public_key";
    };
    sops.secrets."wg/home/endpoint" = {
      inherit sopsFile;
      key = "home/endpoint";
    };

    sops.templates = templates;

    networking.wg-quick.interfaces = {
      home = {
        autostart = true;
        configFile = config.sops.templates."home.conf".path;
      };
    };

    systemd.services = {
      wg-quick-home = {
        after = ["sops-install-secrets.service"];
        wants = ["sops-install-secrets.service"];
      };
    };
  };
}
