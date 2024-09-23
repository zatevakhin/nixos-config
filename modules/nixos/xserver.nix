{pkgs, ...}: {
  # Enable the X11 windowing system.
  services.xserver.enable = true;

  environment.systemPackages = with pkgs; [
    xclip
  ];

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };
}
