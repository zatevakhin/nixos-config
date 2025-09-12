{pkgs, ...}: let
  binding-name = "touchpad-toggle";
  touchpad-toggle = pkgs.writeShellScriptBin "${binding-name}" ''
    gsettings set org.gnome.desktop.peripherals.touchpad send-events $(gsettings get org.gnome.desktop.peripherals.touchpad send-events | grep -q "enabled" && echo "disabled" || echo "enabled")
  '';
in {
  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${binding-name}/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/${binding-name}" = {
      binding = "<Shift><Super>TouchpadOff"; # Now Copilot key is useful
      command = "${touchpad-toggle}/bin/${binding-name}";
      name = "Touchpad toggle";
    };
  };
}
