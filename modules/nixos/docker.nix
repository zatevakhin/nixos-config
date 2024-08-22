{
  pkgs,
  lib,
  ...
}: {
  virtualisation.docker.enable = true;
  virtualisation.docker.enableNvidia = true;
  virtualisation.docker.storageDriver = "btrfs";
  virtualisation.containerd.enable = false;

  hardware.nvidia-container-toolkit.enable = true;

  environment.systemPackages = with pkgs; [
    docker-compose
    docker-buildx
  ];
}
