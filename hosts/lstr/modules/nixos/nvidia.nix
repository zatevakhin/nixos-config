{
  config,
  pkgs,
  lib,
  ...
}: let
  nvidia_modules = ["nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm"];
  nvidia_specific_kernel_params = ["pcie_aspm=off"];
  amd_modules = ["amdgpu"];
in {
  boot.initrd.kernelModules = nvidia_modules;
  boot.blacklistedKernelModules = amd_modules;
  boot.kernelParams = nvidia_specific_kernel_params;

  specialisation = {
    laptop.configuration = {
      system.nixos.tags = ["laptop"];

      boot.initrd.kernelModules = lib.mkForce (lib.pipe config.boot.initrd.kernelModules [
        lib.unique
        (lib.subtractLists nvidia_modules)
        lib.mkAfter
      ]);

      boot.blacklistedKernelModules = lib.mkForce (lib.pipe config.boot.blacklistedKernelModules [
        lib.unique
        (lib.subtractLists amd_modules)
        lib.mkAfter
      ]);

      boot.kernelParams = lib.mkForce (lib.pipe config.boot.kernelParams [
        (lib.subtractLists nvidia_specific_kernel_params)
        (lib.filter (x: !(lib.hasInfix "nvidia" x)))
        lib.mkAfter
      ]);

      services.xserver.videoDrivers = lib.mkForce amd_modules;

      systemd.services.delayed-amdgpu.enable = lib.mkForce false;
      hardware.nvidia.prime.sync.enable = lib.mkForce false;
      hardware.nvidia-container-toolkit.enable = lib.mkForce false;
    };
  };

  services.xserver.videoDrivers = ["nvidia"];

  # NOTE: Now when running containers that require GPUs
  #       use next syntax to add GPUs to container.
  #       $ docker run --rm -it --device=nvidia.com/gpu=all nvidia/cuda...
  hardware.nvidia-container-toolkit.enable = true;

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
