{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    devenv
    direnv
    micromamba
    rustup
    gcc
    clang
    lazygit
  ];
}
