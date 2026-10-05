{...}: {
  flake.nixosModules.logitech = {pkgs, ...}: {
    environment.systemPackages = with pkgs; [
      solaar
      logitech-udev-rules
    ];

    hardware.logitech.wireless.enable = true;
  };
}
