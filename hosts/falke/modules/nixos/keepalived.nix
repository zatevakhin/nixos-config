{...}: {
  # NOTE: Used as workaround to keep same IP for internal and usb ethernet adapters.
  # all this done because network driver for internal adapter crashes over some time.
  services.keepalived = {
    enable = true;
    vrrpInstances = {
      internal = {
        interface = "eno1";
        state = "MASTER";
        virtualRouterId = 50;
        priority = 100;
        virtualIps = [
          {
            addr = "192.168.1.11/32";
            dev = "eno1";
          }
        ];
        trackInterfaces = [
          "eno1"
        ];
      };

      usb = {
        interface = "enp13s0u4";
        state = "BACKUP";
        virtualRouterId = 50;
        priority = 50;
        virtualIps = [
          {
            addr = "192.168.1.11/32";
            dev = "enp13s0u4";
          }
        ];
        noPreempt = true;
      };
    };
  };
}
