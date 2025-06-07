{...}: let
  wg = import ../../secrets/wg.nix;
in {
  networking.wg-quick.interfaces = {
    wg0 = {
      address = ["192.168.5.8/32"];
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
            "192.168.149.0/24" # HW and IGS
          ];
          endpoint = wg.work.endpoint;
          persistentKeepalive = 25;
        }
      ];
    };

    wg1 = {
      address = ["10.8.0.5/24"];
      dns = ["10.0.1.3"] ++ wg.home.search;
      autostart = false;
      listenPort = 51820;
      privateKey = wg.home.private_key;

      peers = [
        {
          publicKey = wg.home.public_key;
          presharedKey = wg.home.preshared_key;
          # allowedIPs = [ "10.8.0.0/24" "10.8.1.0/24" "129.168.1.1/24" ];
          allowedIPs = ["0.0.0.0/0" "::/0"];
          endpoint = wg.home.endpoint;
          persistentKeepalive = 25;
        }
      ];
    };
  };
}
