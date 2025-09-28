{...}: {
  services.keepalived = {
    enable = true;
    vrrpInstances = {
      internal = {
        interface = "enp1s0";
        state = "BACKUP";
        virtualRouterId = 50;
        priority = 50;
        virtualIps = [
          {
            addr = "192.168.1.100/32";
            dev = "enp1s0";
          }
        ];
      };
    };
  };
}
