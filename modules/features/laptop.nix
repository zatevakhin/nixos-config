{self, ...}: {
  flake.nixosModules.laptop = {...}: {
    imports = [self.nixosModules.tlp];

    services.logind.settings.Login = {
      HandlePowerKey = "lock";
      HandleLidSwitch = "lock";
      HandleLidSwitchDocked = "ignore";
      HandleLidSwitchExternalPower = "ignore";
    };
  };
}
