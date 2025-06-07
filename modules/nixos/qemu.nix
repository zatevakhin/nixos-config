{
  pkgs,
  username,
  ...
}: {
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;

  environment.systemPackages = with pkgs; [
    qemu-utils
  ];

  # Add user into docker group.
  users.users.${username}.extraGroups = ["kvm" "libvirtd"];
}
