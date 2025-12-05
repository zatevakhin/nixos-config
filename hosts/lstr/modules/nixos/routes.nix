{...}: {
  # TODO: route trough AEON instead of MNHR. AEON should keep routing table for other crap in net.
  networking.interfaces."eth2".ipv4.routes = [
    {
      address = "10.8.0.0";
      prefixLength = 24;
      via = "192.168.1.10";
    }
  ];

  networking.interfaces."wlp195s0".ipv4.routes = [
    {
      address = "10.8.0.0";
      prefixLength = 24;
      via = "192.168.1.10";
    }
  ];
}
