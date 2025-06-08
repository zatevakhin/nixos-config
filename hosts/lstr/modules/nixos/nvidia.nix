{
  config,
  pkgs,
  lib,
  ...
}: let
  nvidiaModules = ["nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"];
  # removeItems = items: list: lib.filter (x: !(lib.elem x items)) list;
in {
  boot.initrd.kernelModules = nvidiaModules;
  boot.blacklistedKernelModules = ["amdgpu"];

  boot.kernelParams = [
    "pcie_aspm=off"
  ];

  # NOTE: Specialisation partially broken.
  # TODO: Fix specialisation for Laptop/Docked mode. Docked mode is default.
  # specialisation = {
  #   laptop.configuration = {
  #     system.nixos.tags = ["laptop"];
  #     boot.blacklistedKernelModules = lib.mkForce (removeItems ["amdgpu"] config.boot.blacklistedKernelModules);
  #     boot.initrd.kernelModules = lib.unique (removeItems nvidiaModules config.boot.kernelModules);
  #     boot.kernelParams = removeItems ["pcie_aspm=off"] config.boot.kernelParams;
  #     systemd.services.delayed-amdgpu.enable = lib.mkForce false;
  #   };
  # };

  services.xserver.videoDrivers = ["nvidia"];

  # NOTE: Not all display outputs are working if there is no `amdgpu` driver loaded.
  # Delayed loading after display manager is started to use proper driver.
  # - Need to try to start after gdm.service mb will be better. coz some times need to re-plug display.
  systemd.services.delayed-amdgpu = {
    description = "Delayed loading of amdgpu kernel module";
    after = ["display-manager.service"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStartPre = "/run/current-system/sw/bin/sleep 2";
      ExecStart = "/run/current-system/sw/bin/modprobe amdgpu";
      RemainAfterExit = true;
    };
  };

  hardware.nvidia.prime = {
    sync.enable = true;

    amdgpuBusId = "PCI:197:0:0";
    nvidiaBusId = "PCI:196:0:0";
  };

  environment.systemPackages = with pkgs; [
    nvtopPackages.full
  ];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    open = true;

    # Enable the Nvidia settings menu, accessible via `nvidia-settings`.
    nvidiaSettings = false;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;

    # NOTE: Enable if there are screen tearing issues.
    # forceFullCompositionPipeline = true;
  };
}
