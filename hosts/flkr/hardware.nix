{...}: {
  flake.nixosModules.flkr-hardware = {
    modulesPath,
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    # Match the existing partition labels and subvolumes; no repartitioning needed.
    # Never run disko's formatting/install scripts against the populated disk.
    disko = {
      enableConfig = true;
      devices.disk.main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              label = "disk-vdb-ESP";
              size = "2048M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = ["defaults"];
              };
            };
            luks = {
              label = "disk-vdb-luks";
              size = "100%";
              content = {
                type = "luks";
                name = "crypted";
                settings.allowDiscards = true;
                content = {
                  type = "btrfs";
                  subvolumes =
                    lib.genAttrs ["/root" "/home" "/nix" "/projects" "/var/lib/docker" "/var/lib/libvirt" "/var/log"] (subvolume: {
                      mountpoint =
                        if subvolume == "/root"
                        then "/"
                        else subvolume;
                      mountOptions = ["rw" "relatime" "ssd" "space_cache=v2" "compress=zstd"];
                    })
                    // {
                      "/swap" = {
                        mountpoint = "/.swapvol";
                        mountOptions = ["defaults"];
                      };
                    };
                };
              };
            };
          };
        };
      };
    };

    swapDevices = [];

    services.btrfs.autoScrub = {
      enable = true;
      interval = "monthly";
    };

    environment.systemPackages = with pkgs; [cryptsetup sbctl];

    # NOTE: Using `aarch64` emulation to build packages for Raspberry PIs
    boot.binfmt.emulatedSystems = [
      "aarch64-linux"
    ];

    boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "ahci" "usbhid"];
    boot.initrd.kernelModules = [];
    boot.kernelModules = ["kvm-amd"];
    boot.extraModulePackages = [];

    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

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
