{...}: {
  flake.nixosModules.homeworld-certificate = {
    pkgs,
    lib,
    ...
  }: {
    security.pki.certificateFiles = [
      (pkgs.fetchurl {
        url = "https://step-ca.homeworld.lan:8443/roots.pem";
        hash = "sha256-+EsQqEb+jaLKq4/TOUTEwF/9lwU5mETu4MY4GTN1V+A=";
        curlOpts = "--insecure";
      })
    ];
  };
}
