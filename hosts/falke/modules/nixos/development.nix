{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    devenv
    direnv
    micromamba
    lazygit
  ];
}
