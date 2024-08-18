{
  pkgs,
  lib,
  ...
}: {
  virtualisation.docker.enable = true;
  virtualisation.docker.enableNvidia = true;
  virtualisation.docker.storageDriver = "btrfs";
  virtualisation.containerd.enable = lib.mkForce false;

  hardware.nvidia-container-toolkit.enable = lib.mkForce true;

  environment.systemPackages = with pkgs; [
    docker-compose
    docker-buildx
  ];
}
