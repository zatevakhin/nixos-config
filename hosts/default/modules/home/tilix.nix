{pkgs, ...}: {
  dconf.settings = {
    "org/gnome/settings-daemon/plugins/media-keys" = {
      custom-keybindings = [
        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
      ];
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      binding = "F12";
      command = "${pkgs.tilix}/bin/tilix --quake";
      name = "Tilix";
    };

    "com/gexperts/Tilix" = {
      terminal-title-style = "none";
      theme-variant = "dark";
      use-tabs = true;
    };

    "com/gexperts/Tilix/profiles/2b7c4080-0ddd-46c5-8f23-563fd3ba789d" = {
      visible-name = "Default";
      cursor-blink-mode = "system";
      scrollback-unlimited = true;
      terminal-bell = "none";
      use-theme-colors = true;
      palette = ["#000000" "#CC0000" "#4D9A05" "#C3A000" "#3464A3" "#754F7B" "#05979A" "#D3D6CF" "#545652" "#EF2828" "#89E234" "#FBE84F" "#729ECF" "#AC7EA8" "#34E2E2" "#EDEDEB"];
    };
  };
}
