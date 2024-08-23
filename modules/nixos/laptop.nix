{...}: {
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "lock";
    extraConfig = "HandlePowerKey=suspend";
  };
}
