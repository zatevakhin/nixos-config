{...}: {
  flake.nixosModules.mnhr-keepalived = {
    username,
    pkgs,
    ...
  }: {
    services.keepalived = {
      enable = true;
      vrrpInstances = {
        internal = {
          interface = "enP4p65s0";
          state = "BACKUP";
          virtualRouterId = 50;
          priority = 50;
          virtualIps = [
            {
              addr = "192.168.1.100/32";
              dev = "enP4p65s0";
            }
          ];
        };
      };
    };
  };
}
