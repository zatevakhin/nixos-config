{pkgs, ...}: {
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true;
  environment.systemPackages = with pkgs; [mangohud];
}
