{...}: let
  wg = import ../../secrets/wg.nix;
in {
  networking.wg-quick.interfaces = builtins.listToAttrs (map (e: {
      name = "work-${e.name}";
      value = {
        address = [wg.work.address];
        autostart = false;
        listenPort = 51820;
        privateKey = wg.work.private_key;
        peers = [
          {
            publicKey = wg.work.public_key;
            allowedIPs = [
              "192.168.128.0/23"
              "192.168.150.0/24"
              "192.168.5.0/24"
              "192.168.151.0/24"
              "192.168.149.0/24"
            ];
            endpoint = e.endpoint;
            persistentKeepalive = 25;
          }
        ];
      };
    })
    wg.work.endpoints);
}
