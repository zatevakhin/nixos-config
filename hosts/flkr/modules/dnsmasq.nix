{...}: {
  flake.nixosModules.flkr-dnsmasq = {
    inputs,
    lib,
    ...
  }: let
    work = lib.importTOML "${inputs.notsecrets}/work/wg.toml";
  in {
    services.dnsmasq = {
      enable = true;
      settings = {
        listen-address = "127.0.0.1";
        server =
          (map (domain: "/${domain}/${work.peer.dns}") work.peer.search)
          ++ [
            "/lan/192.168.1.100"
            "192.168.1.100"
            "9.9.9.10"
            "1.1.1.1"
            "1.0.0.1"
          ];
        no-resolv = true;
        no-poll = true;
        cache-size = 1000;
      };
    };
  };
}
