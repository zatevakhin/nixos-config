{...}: {
  services.keepalived = {
    enable = true;
    vrrpInstances = {
      internal = {
        interface = "end0";
        state = "MASTER";
        virtualRouterId = 50;
        priority = 100;
        virtualIps = [
          {
            addr = "192.168.1.100/32";
            dev = "end0";
          }
        ];
      };
    };
  };
}
