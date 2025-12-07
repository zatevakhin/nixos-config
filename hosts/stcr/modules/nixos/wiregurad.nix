{...}: let
  wg = import ../../secrets/wg.nix;
in {
  networking.wg-quick.interfaces = {
    home = {
      address = ["10.8.0.3/32"];
      dns = ["192.168.1.100"] ++ wg.home.search;
      autostart = true;
      listenPort = 51820;
      privateKey = wg.home.private_key;

      peers = [
        {
          publicKey = wg.home.public_key;
          presharedKey = wg.home.preshared_key;
          allowedIPs = ["10.8.0.3/32" "192.168.1.0/24"];
          endpoint = wg.home.endpoint;
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
