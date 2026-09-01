{...}: {
  flake.nixosModules.kernel-latest = {pkgs, ...}: {
    boot.kernelPackages = pkgs.linuxPackages_latest;
  };
}
