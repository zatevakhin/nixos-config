{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    vscode
    devenv
    direnv
    micromamba
    rustup
    gcc
    clang
    pkg-config
    lazygit
  ];
}
