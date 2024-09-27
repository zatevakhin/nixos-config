{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    devenv
    direnv
    micromamba
    rustup
    rerun
    gcc
    clang
    pkg-config
    lazygit
  ];
}
