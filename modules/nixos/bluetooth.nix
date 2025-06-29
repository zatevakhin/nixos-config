{...}: {
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings = {
      General = {
        Enable = "Control,Gateway,Headset,Media,Sink,Socket,Source";
        ControllerMode = "dual";
        Experimental = true;
        KernelExperimental = "6fbaf188-05e0-496a-9885-d6ddfdb4e03e,a6695ace-ee7f-4fb9-881a-5fac66c629af,330859bc-7506-492d-9370-9a6f0614037f,330859bc-7506-492d-9370-9a6f0614037f,330859bc-7506-492d-9370-9a6f0614037f";
      };
    };
  };
}
