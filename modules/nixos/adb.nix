{
  pkgs,
  username,
  ...
}: {
  programs.adb.enable = true;

  services.udev.packages = with pkgs; [
    android-udev-rules
  ];

  users.users.${username}.extraGroups = ["adbusers"];
}
