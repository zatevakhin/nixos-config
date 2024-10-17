{
  config,
  lib,
  ...
}: {
  services.xserver.displayManager.gdm.wayland = lib.mkForce true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    # NOTE: If not enough env variables from nvidia offload can be added.
  };

  boot.kernelParams = ["module_blacklist=i915"];

  # NOTE: Use Intel GPU in Laptop mode on Wayland.
  specialisation = {
    laptop.configuration = {
      system.nixos.tags = ["laptop"];
      boot.kernelParams = lib.mkForce (lib.filter (param: param != "module_blacklist=i915") config.boot.kernelParams);
    };
  };
}
