{...}: {
  services.tor = {
    enable = true;
    client.enable = true;
    enableGeoIP = false;
  };
}
