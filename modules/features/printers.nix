{...}: {
  flake.nixosModules.printers = {...}: {
    services.ipp-usb.enable = true;
    services.printing.enable = true;
  };
}
