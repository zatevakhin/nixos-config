{...}: {
  flake.nixosModules.gaming = {
    pkgs-unstable,
    pkgs,
    lib,
    ...
  }: {
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
    };

    nixpkgs.overlays = [
      (self: super: {atlauncher = pkgs-unstable.atlauncher;})
    ];

    environment.systemPackages = with pkgs; [mangohud protonup-rs atlauncher];
  };
}
