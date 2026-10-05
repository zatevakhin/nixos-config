{...}: {
  flake.nixosModules.sys3-hardware = {
    modulesPath,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    # <disko>
    disko.devices = {
      disk = {
        main = {
          type = "disk";
          device = "/dev/nvme0n1";
          content = {
            type = "gpt";
            partitions = {
              ESP = {
                size = "1024M";
                type = "EF00";
                content = {
                  type = "filesystem";
                  format = "vfat";
                  mountpoint = "/boot";
                  mountOptions = [
                    "defaults"
                  ];
                };
              };
              root = {
                size = "100%";
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/";
                  mountOptions = [
                    "noatime"
                  ];
                };
              };
            };
          };
        };
      };
    };
    # </disko>

    # <jetson specific>
    hardware.nvidia-jetpack = {
      enable = true;
      som = "orin-agx";
      carrierBoard = "devkit";
      maxClock = true;
    };

    services.nvpmodel = {
      enable = true;
      # 0 = MAXN. 3 = 50W on 64GB (all cores, still power-capped).
      profileNumber = 0;
    };
    # </jetson specific>

    # Bootloader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    hardware.deviceTree.enable = true;

    boot.initrd.availableKernelModules = ["nvme" "usbhid"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = [];
    boot.extraModulePackages = [];

    # Enable GPU support - needed even for CUDA and containers
    hardware.graphics.enable = true;

    # Enable various firmware support
    hardware.enableRedistributableFirmware = true;

    # Enable to use DHCP by default
    networking.useDHCP = lib.mkDefault true;

    # Set host platform as aarch64 device, used in cross-compilation cases
    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  };
}
