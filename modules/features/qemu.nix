{...}: {
  flake.nixosModules.qemu = {
    username,
    pkgs,
    ...
  }: {
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    environment.systemPackages = with pkgs; [
      qemu-utils
    ];

    users.users.${username}.extraGroups = ["kvm" "libvirtd"];
  };
}
