{...}: {
  flake.nixosModules.development = {
    username,
    pkgs,
    ...
  }: {
    environment.systemPackages = with pkgs; [
      devenv
      direnv
    ];
  };
}
