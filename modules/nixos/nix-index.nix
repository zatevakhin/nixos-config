{...}: {
  programs.nix-index.enable = true;
  programs.nix-index.enableZshIntegration = true;
  programs.nix-index.enableBashIntegration = false;
  programs.command-not-found.enable = false;
}
