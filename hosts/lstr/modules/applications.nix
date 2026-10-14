{...}: {
  flake.nixosModules.lstr-applications = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      keepassxc
      mumble
      godot
      rnote

      nmap
      sqlite
      (pkgs.callPackage ../../../flakes/omnigraph/package.nix {}).omnigraph-cli
      yt-dlp
    ];
  };
}
