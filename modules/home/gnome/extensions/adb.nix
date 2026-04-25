{...}: {
  flake.nixosModules.adb = {
    username,
    pkgs,
    ...
  }: {
    programs.adb.enable = true;
    users.users.${username}.extraGroups = ["adbusers"];

    environment.systemPackages = with pkgs; [android-tools];
  };
}
