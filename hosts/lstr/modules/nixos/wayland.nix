{
  lib,
  username,
  ...
}: {
  services.xserver.displayManager.gdm.wayland = lib.mkForce true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    XCURSOR_SIZE = lib.mkForce "12"; # BUG: Cursor oversized on Xwayland applications
    # NOTE: If not enough env variables from nvidia offload can be added.
  };

  environment.variables = {
    XCURSOR_SIZE = lib.mkForce "12"; # BUG: Cursor oversized on Xwayland applications
  };

  programs.ydotool.enable = true;
  users.users.${username}.extraGroups = ["ydotool"];
}
