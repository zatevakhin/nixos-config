{...}: {
  flake.nixosModules.docker = {
    username,
    pkgs,
    ...
  }: {
    virtualisation.docker.enable = true;

    environment.systemPackages = with pkgs; [
      docker-compose
      docker-buildx
    ];

    users.users.${username}.extraGroups = ["docker"];
  };
}
