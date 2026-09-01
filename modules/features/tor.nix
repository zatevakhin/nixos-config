{...}: {
  flake.nixosModules.tor = {...}: {
    services.tor = {
      enable = true;
      client.enable = true;
      enableGeoIP = true;
    };
  };
}
