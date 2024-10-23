{
  pkgs,
  username,
  ...
}: {
  virtualisation.docker.enable = true;

  environment.systemPackages = with pkgs; [
    docker-compose
    docker-buildx
  ];

  # Add user into docker group.
  users.users.${username}.extraGroups = ["docker"];
}
