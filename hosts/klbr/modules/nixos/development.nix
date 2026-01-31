{
  pkgs,
  pkgs-unstable,
  ...
}: {
  environment.systemPackages =
    (with pkgs; [
      devenv
      direnv
      godot
      gcc
      bun
      uv
      nodejs
      wl-clipboard
      jujutsu
    ])
    ++ (with pkgs-unstable; [
      codex
      cursor-cli
      claude-code
    ]);
}
