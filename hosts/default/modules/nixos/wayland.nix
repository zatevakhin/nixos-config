{lib, ...}: {
  services.xserver.displayManager.gdm.wayland = lib.mkForce true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    # NOTE: If not enough env variables from nvidia offload can be added.
  };

  # TODO: Add on the go mode to use Intel drver.
  boot.kernelParams = ["module_blacklist=i915"];
}
