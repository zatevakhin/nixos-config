{...}: {
  flake.nixosModules.nvidia = {...}: {
    services.xserver.videoDrivers = [
      "amdgpu"
      "nvidia"
    ];

    hardware.nvidia.prime = {
      sync.enable = true;

      amdgpuBusId = "PCI:197:0:0";
      nvidiaBusId = "PCI:196:0:0";
    };
  };
}
