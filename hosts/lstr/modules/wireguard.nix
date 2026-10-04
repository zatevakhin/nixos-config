{...}: {
  flake.nixosModules.lstr-wireguard = {
    hostname,
    config,
    inputs,
    lib,
    ...
  }: let
    inherit (lib) concatStringsSep optionalString;

    home = lib.importTOML "${inputs.notsecrets}/personal/${hostname}.toml";
    work = lib.importTOML "${inputs.notsecrets}/work/wg.toml";

    sopsFile = ../../../secrets/${hostname}/wg.yaml;

    dnsLine = servers: search: let
      all = servers ++ search;
    in
      optionalString (all != []) "DNS = ${concatStringsSep ", " all}";

    workDns =
      if config.services.dnsmasq.enable
      then []
      else [work.peer.dns];

    workConf = endpoint: ''
      [Interface]
      Address = ${work.machine.ip}
      PrivateKey = ${config.sops.placeholder."wg/work/private_key"}
      ListenPort = 51820
      ${dnsLine workDns work.peer.search}

      [Peer]
      PublicKey = ${work.peer.public_key}
      AllowedIPs = ${concatStringsSep ", " work.peer.allowed_ips}
      Endpoint = ${endpoint}
      PersistentKeepalive = 25
    '';

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

    templates =
      builtins.listToAttrs (map (e: {
          name = "work-${e.name}.conf";
          value = {
            content = workConf e.value;
            mode = "0400";
          };
        })
        work.endpoints)
      // {
        "home.conf" = {
          content = homeConf;
          mode = "0400";
        };
      };
  in {
    sops.secrets."wg/work/private_key" = {
      inherit sopsFile;
      key = "work/private_key";
    };
    sops.secrets."wg/home/private_key" = {
      inherit sopsFile;
      key = "home/private_key";
    };
    sops.secrets."wg/home/preshared_key" = {
      inherit sopsFile;
      key = "home/preshared_key";
    };

    sops.templates = templates;

    networking.wg-quick.interfaces =
      builtins.listToAttrs (map (e: {
          name = "work-${e.name}";
          value = {
            autostart = false;
            configFile = config.sops.templates."work-${e.name}.conf".path;
          };
        })
        work.endpoints)
      // {
        home = {
          autostart = false;
          configFile = config.sops.templates."home.conf".path;
        };
      };

    systemd.services =
      builtins.listToAttrs (map (e: {
          name = "wg-quick-work-${e.name}";
          value = {
            after = ["sops-install-secrets.service"];
            wants = ["sops-install-secrets.service"];
          };
        })
        work.endpoints)
      // {
        wg-quick-home = {
          after = ["sops-install-secrets.service"];
          wants = ["sops-install-secrets.service"];
        };
      };
  };
}
