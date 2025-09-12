{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    devenv
    direnv
    godot
    gcc
    bun
    uv
    nodejs
    wl-clipboard
    jujutsu
  ];
}
