{...}: {
  flake.nixosModules.development = {
    username,
    pkgs,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      jujutsu
      devenv
      direnv
      bun
      uv
    ];
  };
}
