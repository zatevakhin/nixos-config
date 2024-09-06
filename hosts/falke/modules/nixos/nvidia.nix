{
  config,
  pkgs,
  ...
}: {
  boot.initrd.kernelModules = ["nvidia"];

  services.xserver.videoDrivers = ["nvidia"];

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
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;

    # Enable the Nvidia settings menu,
    # accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    # package = config.boot.kernelPackages.nvidiaPackages.stable;

    # NOTE: Used to fix issues with vulkan and missing `libnvidia-gpucomp.so` in docker.
    package = config.boot.kernelPackages.nvidiaPackages.stable.overrideAttrs {
      src = pkgs.fetchurl {
        url = "https://download.nvidia.com/XFree86/Linux-x86_64/535.179/NVIDIA-Linux-x86_64-535.179.run";
        hash = "sha256-tDmkUYaZ5S7MdKqtZUEEIlBvH2WaIKIoj+MLUxizcuc=";
      };
    };

    # Screen Tearing Issues
    forceFullCompositionPipeline = true;
  };
}