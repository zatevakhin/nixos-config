{hostname, ...}: let
  domain = "jellyseerr.homeworld.lan";
in {
  services.adguardhome.settings.filtering.rewrites = [
    {
      domain = domain;
      answer = "${hostname}.lan";
    }
  ];

  services.jellyseerr = {
    enable = true;
    openFirewall = false;
  };
}
