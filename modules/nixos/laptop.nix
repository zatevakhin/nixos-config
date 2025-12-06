{...}: {
  services.logind.settings.Login = {
    HandleLidSwitch = "lock";
    HandleLidSwitchDocked = "lock";
    HandleLidSwitchExternalPower = "lock";
    HandlePowerKey = "suspend";
  };
}
