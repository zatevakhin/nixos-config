{
  pkgs,
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/mmcblk0";
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
      # <jbod>
      nvme0 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptnvme0";
                settings = {
                  allowDiscards = true;
                  keyFile = "/root/nvme.keyfile";
                };
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/mnt/nvme0";
                };
              };
            };
          };
        };
      };
      nvme1 = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptnvme1";
                settings = {
                  allowDiscards = true;
                  keyFile = "/root/nvme.keyfile";
                };
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/mnt/nvme1";
                };
              };
            };
          };
        };
      };
      nvme2 = {
        type = "disk";
        device = "/dev/nvme2n1";
        content = {
          type = "gpt";
          partitions = {
            data = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptnvme2";
                settings = {
                  allowDiscards = true;
                  keyFile = "/root/nvme.keyfile";
                };
                content = {
                  type = "filesystem";
                  format = "ext4";
                  mountpoint = "/mnt/nvme2";
                };
              };
            };
          };
        };
      };
      # </jbod>
    };
  };

  # MergerFS configuration
  fileSystems."/mnt/storage" = {
    device = "/mnt/nvme0:/mnt/nvme1:/mnt/nvme2";
    fsType = "fuse.mergerfs";
    options = [
      "defaults"
      "allow_other"
      "use_ino"
      "cache.files=partial"
      "dropcacheonclose=true"
      "category.create=mfs"
    ];
  };

  # Ensure encrypted devices are mounted at boot
  boot.initrd.luks.devices = {
    cryptnvme0 = {
      device = "/dev/disk/by-partlabel/disk-nvme0-data";
      keyFile = "/root/nvme.keyfile";
      allowDiscards = true;
    };
    cryptnvme1 = {
      device = "/dev/disk/by-partlabel/disk-nvme1-data";
      keyFile = "/root/nvme.keyfile";
      allowDiscards = true;
    };
    cryptnvme2 = {
      device = "/dev/disk/by-partlabel/disk-nvme2-data";
      keyFile = "/root/nvme.keyfile";
      allowDiscards = true;
    };
  };

  boot.initrd.secrets = {
    "/root/nvme.keyfile" = "/root/nvme.keyfile";
  };

  # Added MergerFS package
  environment.systemPackages = [pkgs.mergerfs pkgs.cryptsetup];

  boot.initrd.availableKernelModules = ["nvme" "usbhid"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  boot.supportedFilesystems.zfs = true;
  boot.zfs.package = pkgs.zfs;

  hardware.enableRedistributableFirmware = true;
  hardware.deviceTree = {
    enable = true;
    name = "rockchip/rk3588-friendlyelec-cm3588-nas.dtb";
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
