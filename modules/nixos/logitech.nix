{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    # Logitech Mouse & Keyboard
    solaar
    logitech-udev-rules
  ];

  hardware.logitech.wireless.enable = true;
}
