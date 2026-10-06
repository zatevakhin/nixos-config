{...}: {
  # 7.4 GB RAM OOMs Rust links. zram first, then a 16 GiB nvme swapfile.
  flake.nixosModules.nano-swap = {lib, ...}: {
    swapDevices = [
      {
        device = "/var/lib/swapfile";
        size = 16 * 1024;
        priority = 10;
      }
    ];

    zramSwap = {
      enable = true;
      algorithm = "zstd";
      memoryPercent = 50;
      priority = 100;
    };

    boot.kernel.sysctl."vm.swappiness" = lib.mkDefault 10;
  };
}
