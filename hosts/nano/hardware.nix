{...}: {
  flake.nixosModules.nano-hardware = {
    modulesPath,
    lib,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    # Describes the disk nano is already installed on. Do not run disko
    # against this host; that would wipe /dev/nvme0n1.
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

    hardware.nvidia-jetpack = {
      enable = true;
      som = "orin-nano";
      carrierBoard = "devkit";
    };

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    hardware.deviceTree.enable = true;

    boot.initrd.availableKernelModules = ["nvme" "usbhid"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = [];
    boot.extraModulePackages = [];

    hardware.graphics.enable = true;
    hardware.enableRedistributableFirmware = true;

    networking.useDHCP = lib.mkDefault true;
    nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  };
}
