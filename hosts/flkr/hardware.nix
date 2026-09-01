{...}: {
  flake.nixosModules.flkr-hardware = {
    modulesPath,
    hostname,
    config,
    pkgs,
    lib,
    ...
  }: let
    devices = import ../../secrets/${hostname}/devices.nix;
  in {
    imports = [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

    boot.initrd.luks.devices."${devices.fs.luks.root.name}".device = "/dev/disk/by-uuid/${devices.fs.luks.root.uuid}";

    fileSystems."/" = {
      device = "/dev/disk/by-uuid/${devices.fs.open.root.uuid}";
      fsType = "btrfs";
      options = ["rw" "relatime" "ssd" "space_cache=v2" "compress=zstd" "subvol=root"];
    };

    fileSystems."/.swapvol" = {
      device = "/dev/disk/by-uuid/${devices.fs.open.root.uuid}";
      fsType = "btrfs";
      options = ["defaults" "subvol=swap"];
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-uuid/${devices.fs.boot.uuid}";
      fsType = "vfat";
    };

    fileSystems."/home" = {
      device = "/dev/disk/by-uuid/${devices.fs.open.root.uuid}";
      fsType = "btrfs";
      options = ["rw" "relatime" "ssd" "space_cache=v2" "compress=zstd" "subvol=home"];
    };

    fileSystems."/nix" = {
      device = "/dev/disk/by-uuid/${devices.fs.open.root.uuid}";
      fsType = "btrfs";
      options = ["rw" "relatime" "ssd" "space_cache=v2" "compress=zstd" "subvol=nix"];
    };

    fileSystems."/projects" = {
      device = "/dev/disk/by-uuid/${devices.fs.open.root.uuid}";
      fsType = "btrfs";
      options = ["rw" "relatime" "ssd" "space_cache=v2" "compress=zstd" "subvol=projects"];
    };

    fileSystems."/var/lib/docker" = {
      device = "/dev/disk/by-uuid/${devices.fs.open.root.uuid}";
      fsType = "btrfs";
      options = ["rw" "relatime" "ssd" "space_cache=v2" "compress=zstd" "subvol=var/lib/docker"];
    };

    fileSystems."/var/lib/libvirt" = {
      device = "/dev/disk/by-uuid/${devices.fs.open.root.uuid}";
      fsType = "btrfs";
      options = ["rw" "relatime" "ssd" "space_cache=v2" "compress=zstd" "subvol=var/lib/libvirt"];
    };

    fileSystems."/var/log" = {
      device = "/dev/disk/by-uuid/${devices.fs.open.root.uuid}";
      fsType = "btrfs";
      options = ["rw" "relatime" "ssd" "space_cache=v2" "compress=zstd" "subvol=var/log"];
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
