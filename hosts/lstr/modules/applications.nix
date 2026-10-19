{...}: {
  flake.nixosModules.lstr-applications = {
    pkgs,
    pkgs-unstable,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      keepassxc
      mumble
      godot
      rnote

      pkgs-unstable.glab
      nmap
      sqlite
      (pkgs.callPackage ../../../flakes/omnigraph/package.nix {}).omnigraph-cli
      yt-dlp
    ];
  };
}
