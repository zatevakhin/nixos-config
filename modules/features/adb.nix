{...}: {
  flake.nixosModules.adb = {
    username,
    pkgs,
    ...
  }: {
    users.users.${username}.extraGroups = ["adbusers"];

    environment.systemPackages = with pkgs; [android-tools];
  };
}
