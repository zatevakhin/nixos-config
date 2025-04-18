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
      # ZFS RAIDZ1 setup
      nvme0 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptnvme0";
                settings = {
                  allowDiscards = true;
                  keyFile = "/root/nvme.keyfile";
                };
                content = {
                  type = "zfs";
                  pool = "storage";
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
            zfs = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptnvme1";
                settings = {
                  allowDiscards = true;
                  keyFile = "/root/nvme.keyfile";
                };
                content = {
                  type = "zfs";
                  pool = "storage";
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
            zfs = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptnvme2";
                settings = {
                  allowDiscards = true;
                  keyFile = "/root/nvme.keyfile";
                };
                content = {
                  type = "zfs";
                  pool = "storage";
                };
              };
            };
          };
        };
      };
      nvme3 = {
        type = "disk";
        device = "/dev/nvme3n1";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptnvme3";
                settings = {
                  allowDiscards = true;
                  keyFile = "/root/nvme.keyfile";
                };
                content = {
                  type = "zfs";
                  pool = "storage";
                };
              };
            };
          };
        };
      };
    };
    zpool = {
      storage = {
        type = "zpool";
        mode = "raidz1";
        mountpoint = "/storage";
        datasets = {
          "media" = {
            type = "zfs_fs";
            mountpoint = "/storage/media";
            options = {
              compression = "lz4";
              atime = "off";
              xattr = "sa";
            };
          };
          "downloads" = {
            type = "zfs_fs";
            mountpoint = "/storage/downloads";
            options = {
              compression = "lz4";
              atime = "off";
              xattr = "sa";
            };
          };
          "docker" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/docker";
            options = {
              compression = "lz4";
              atime = "off";
              xattr = "sa";
            };
          };
          "services" = {
            type = "zfs_fs";
            mountpoint = "/storage/.services";
            options = {
              compression = "lz4";
              atime = "off";
              xattr = "sa";
            };
          };
        };
      };
    };
  };

  # Ensure encrypted devices are mounted at boot
  boot.initrd.luks.devices = {
    cryptnvme0 = {
      device = "/dev/disk/by-partlabel/disk-nvme0-zfs";
      keyFile = "/root/nvme.keyfile";
      allowDiscards = true;
    };
    cryptnvme1 = {
      device = "/dev/disk/by-partlabel/disk-nvme1-zfs";
      keyFile = "/root/nvme.keyfile";
      allowDiscards = true;
    };
    cryptnvme2 = {
      device = "/dev/disk/by-partlabel/disk-nvme2-zfs";
      keyFile = "/root/nvme.keyfile";
      allowDiscards = true;
    };
    cryptnvme3 = {
      device = "/dev/disk/by-partlabel/disk-nvme3-zfs";
      keyFile = "/root/nvme.keyfile";
      allowDiscards = true;
    };
  };

  boot.initrd.secrets = {
    "/root/nvme.keyfile" = "/root/nvme.keyfile";
  };

  # Added MergerFS package
  environment.systemPackages = with pkgs; [cryptsetup zfs zfstools];

  boot.initrd.availableKernelModules = ["nvme" "usbhid"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  boot.supportedFilesystems.zfs = true;
  boot.zfs.package = pkgs.zfs;

  services.zfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };

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
