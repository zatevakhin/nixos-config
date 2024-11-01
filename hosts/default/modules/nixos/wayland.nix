{
  config,
  lib,
  username,
  ...
}: {
  services.xserver.displayManager.gdm.wayland = lib.mkForce true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    QT_QPA_PLATFORM = "wayland";
    # NOTE: If not enough env variables from nvidia offload can be added.
  };

  boot.blacklistedKernelModules = ["i915"];

  # NOTE: Use Intel GPU in Laptop mode on Wayland.
  specialisation = {
    laptop.configuration = {
      system.nixos.tags = ["laptop"];
      boot.blacklistedKernelModules = lib.mkForce (lib.filter (param: param != "i915") config.boot.blacklistedKernelModules);
    };
  };

  programs.ydotool.enable = true;
  users.users.${username}.extraGroups = ["ydotool"];
}
