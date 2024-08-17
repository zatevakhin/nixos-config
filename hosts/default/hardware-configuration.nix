{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: let
  devices = import ./secrets/devices.nix;
in {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot.initrd.availableKernelModules = ["xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod"];
  boot.initrd.kernelModules = [];
  boot.kernelModules = ["kvm-intel"];
  boot.extraModulePackages = [];

  boot.initrd.luks.devices."${devices.fs.luks.root.name}".device = "/dev/disk/by-uuid/${devices.fs.luks.root.uuid}";
  boot.initrd.luks.devices."${devices.fs.luks.swap.name}".device = "/dev/disk/by-uuid/${devices.fs.luks.swap.uuid}";

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/${devices.fs.open.root.uuid}";
    fsType = "btrfs";
    options = ["rw" "relatime" "ssd" "space_cache=v2" "compress=zstd" "subvol=@root"];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/${devices.fs.open.root.uuid}";
    fsType = "btrfs";
    options = ["rw" "relatime" "ssd" "space_cache=v2" "compress=zstd" "subvol=@home"];
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/${devices.fs.open.root.uuid}";
    fsType = "btrfs";
    options = ["rw" "relatime" "ssd" "space_cache=v2" "compress=zstd" "subvol=@nix"];
  };

  fileSystems."/projects" = {
    device = "/dev/disk/by-uuid/${devices.fs.open.root.uuid}";
    fsType = "btrfs";
    options = ["rw" "relatime" "ssd" "space_cache=v2" "compress=zstd" "subvol=@projects"];
  };

  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/${devices.fs.open.root.uuid}";
    fsType = "btrfs";
    options = ["rw" "relatime" "ssd" "space_cache=v2" "compress=zstd" "subvol=@log"];
  };

  fileSystems."/var/lib/libvirt" = {
    device = "/dev/disk/by-uuid/${devices.fs.open.root.uuid}";
    fsType = "btrfs";
    options = ["rw" "relatime" "ssd" "space_cache=v2" "compress=zstd" "subvol=@libvirt"];
  };

  fileSystems."/var/lib/docker" = {
    device = "/dev/disk/by-uuid/${devices.fs.open.root.uuid}";
    fsType = "btrfs";
    options = ["rw" "relatime" "ssd" "space_cache=v2" "compress=zstd" "subvol=@docker"];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/${devices.fs.boot.uuid}";
    fsType = "vfat";
  };

  swapDevices = [
    {device = "/dev/disk/by-uuid/${devices.fs.open.swap.uuid}";}
  ];

  services.btrfs.autoScrub = {
    enable = true;
    interval = "monthly";
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
