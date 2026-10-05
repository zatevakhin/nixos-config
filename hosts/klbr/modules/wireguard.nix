{...}: {
  flake.nixosModules.klbr-wireguard = {
    hostname,
    config,
    inputs,
    lib,
    ...
  }: let
    inherit (lib) concatStringsSep optionalString;

    home = lib.importTOML "${inputs.notsecrets}/personal/${hostname}.toml";

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
      PublicKey = ${home.peer.public_key}
      PresharedKey = ${config.sops.placeholder."wg/home/preshared_key"}
      AllowedIPs = ${concatStringsSep ", " home.peer.allowed_ips}
      Endpoint = ${home.peer.endpoint}
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

    sops.templates = templates;

    networking.wg-quick.interfaces = {
      home = {
        autostart = false;
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
