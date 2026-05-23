{...}: {
  flake.nixosModules.opentabletdriver = {...}: {
    hardware.opentabletdriver = {
      enable = true;
      daemon.enable = true;
    };
  };
}
