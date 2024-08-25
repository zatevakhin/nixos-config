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

  boot = {
    kernelPackages = pkgs.linuxKernel.packages.linux_rpi4;
    initrd.availableKernelModules = ["xhci_pci" "usbhid" "usb_storage"];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible.enable = true;
    };
  };

  environment.etc.crypttab.text = ''
    ${devices.fs.luks.archive-a.name} UUID=${devices.fs.luks.archive-a.name} /root/btrfs-${devices.fs.luks.archive-a.name}.keyfile luks
    ${devices.fs.luks.archive-b.name} UUID=${devices.fs.luks.archive-b.name} /root/btrfs-${devices.fs.luks.archive-b.name}.keyfile luks
  '';

  boot.initrd.kernelModules = [];
  boot.extraModulePackages = [];

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = ["noatime"];
    };

    "/var/lib/docker" = {
      device = "/dev/disk/by-uuid/${devices.fs.open.storage.uuid}";
      fsType = "btrfs";
      options = ["rw" "relatime" "ssd" "space_cache=v2" "compress=zstd" "subvol=@docker"];
    };
    "/mnt/storage/downloads" = {
      device = "/dev/disk/by-uuid/${devices.fs.open.storage.uuid}";
      fsType = "btrfs";
      options = ["rw" "relatime" "ssd" "space_cache=v2" "compress=zstd" "subvol=@downloads"];
    };
    "/mnt/storage/books" = {
      device = "/dev/disk/by-uuid/${devices.fs.open.storage.uuid}";
      fsType = "btrfs";
      options = ["rw" "relatime" "ssd" "space_cache=v2" "compress=zstd" "subvol=@books"];
    };
    "/mnt/storage/syncthing" = {
      device = "/dev/disk/by-uuid/${devices.fs.open.storage.uuid}";
      fsType = "btrfs";
      options = ["rw" "relatime" "ssd" "space_cache=v2" "compress=zstd" "subvol=@syncthing"];
    };
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
  hardware.enableRedistributableFirmware = true;
}
