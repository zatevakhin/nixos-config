{...}: {
  flake.nixosModules.sapr-hardware = {
    modulesPath,
    hostname,
    config,
    pkgs,
    lib,
    ...
  }: let
    nvmeDisks = ["nvme0" "nvme1" "nvme2" "nvme3" "nvme4" "nvme5"];

    mkNvme = name: {
      type = "disk";
      device = "/dev/${name}n1";
      content = {
        type = "gpt";
        partitions = {
          zfs = {
            size = "100%";
            content = {
              type = "luks";
              name = "crypt${name}";
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

    zfsDataset = mountpoint: {
      type = "zfs_fs";
      inherit mountpoint;
      options = {
        mountpoint = "legacy";
        compression = "lz4";
        atime = "off";
        xattr = "sa";
        acltype = "posixacl";
      };
    };
  in {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    disko.devices = {
      disk =
        {
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
        }
        // lib.genAttrs nvmeDisks mkNvme;

      zpool = {
        storage = {
          type = "zpool";
          mode = "raidz2";
          mountpoint = "/storage";
          options = {
            ashift = "12";
            autotrim = "on";
          };
          rootFsOptions = {
            mountpoint = "legacy";
            compression = "lz4";
            atime = "off";
            xattr = "sa";
            acltype = "posixacl";
            dnodesize = "auto";
          };
          datasets = {
            media = zfsDataset "/storage/media";
            downloads = zfsDataset "/storage/downloads";
            backups = zfsDataset "/storage/backups";
            syncthing = zfsDataset "/storage/syncthing";
            docker = zfsDataset "/var/lib/docker";
            services = zfsDataset "/storage/.services";
          };
        };
      };
    };

    # Ensure encrypted devices are mounted at boot
    boot.initrd.luks.devices = lib.listToAttrs (map (name: {
        name = "crypt${name}";
        value = {
          device = "/dev/disk/by-partlabel/disk-${name}-zfs";
          keyFile = "/root/nvme.keyfile";
          allowDiscards = true;
        };
      })
      nvmeDisks);

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;
    boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "usbhid" "usb_storage" "sd_mod"];
    boot.initrd.kernelModules = ["mmc_block" "sdhci" "sdhci-pci"];
    boot.kernelModules = ["kvm-intel"];
    boot.extraModulePackages = [];

    # <zfs>
    boot.supportedFilesystems.zfs = true;
    boot.zfs.package = pkgs.zfs;
    boot.zfs.forceImportRoot = false;

    services.zfs.autoScrub = {
      enable = true;
      interval = "monthly";
    };
    # </zfs>

    boot.initrd.secrets = {
      "/root/nvme.keyfile" = "/root/nvme.keyfile";
    };

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

    # NOTE: Enable all firmware regardless of license.
    hardware.enableAllFirmware = true;
  };
}
