{...}: {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Control,Gateway,Headset,Media,Sink,Socket,Source";
        ControllerMode = "bredr";
        Experimental = true;
      };
    };
  };
}
