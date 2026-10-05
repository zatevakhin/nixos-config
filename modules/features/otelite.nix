{inputs, ...}: {
  flake.nixosModules.otelite = {pkgs, ...}: let
    otelitePkgs = import inputs.nixpkgs-otelite {inherit (pkgs) system;};
  in {
    imports = [
      "${inputs.nixpkgs-otelite}/nixos/modules/services/monitoring/otelite.nix"
    ];

    services.otelite = {
      enable = true;
      package = otelitePkgs.otelite;
      address = "0.0.0.0";
      port = 3000;
      otlpGrpcPort = 4317;
      otlpHttpPort = 4318;
      retentionDays = 90;
      openFirewall = true;
    };

    environment.systemPackages = [otelitePkgs.otelite];
  };
}
