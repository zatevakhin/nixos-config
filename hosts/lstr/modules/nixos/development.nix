{
  pkgs,
  pkgs-unstable,
  inputs,
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
      gh
      nodejs
      wl-clipboard
      jujutsu
    ])
    ++ (with pkgs-unstable; [
      codex
      cursor-cli
      claude-code
    ])
    ++ [
      inputs.beads.packages.${pkgs.system}.default
    ];
}
