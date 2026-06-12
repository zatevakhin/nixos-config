{...}: {
  flake.nixosModules.lstr-applications = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      keepassxc
      mumble
      godot
      rnote

      nmap
      sqlite
      yt-dlp
    ];
  };
}
