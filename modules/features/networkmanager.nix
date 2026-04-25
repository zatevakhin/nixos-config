{...}: {
  flake.nixosModules.networkmanager = {
    hostname,
    username,
    ...
  }: {
    networking.hostName = hostname;
    networking.networkmanager.enable = true;
    users.users."${username}".extraGroups = [
      "networkmanager"
    ];
  };
}
