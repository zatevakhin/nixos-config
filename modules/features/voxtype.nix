{inputs, ...}: {
  flake.nixosModules.voxtype = {
    config,
    username,
    pkgs,
    lib,
    ...
  }: let
    voxtype = config.programs.voxtype.package;
    ydotoolSocket = config.environment.variables.YDOTOOL_SOCKET;
  in {
    imports = [inputs.voxtype.nixosModules.default];

    programs.voxtype = {
      enable = true;
      package = lib.mkDefault inputs.voxtype.packages.${pkgs.stdenv.hostPlatform.system}.default;
    };

    # GNOME does not support wtype's virtual-keyboard protocol.
    programs.ydotool.enable = true;
    users.users.${username}.extraGroups = [config.programs.ydotool.group];

    home-manager.sharedModules = [
      ({...}: {
        imports = [inputs.voxtype.homeManagerModules.default];

        programs.voxtype = {
          enable = true;
          package = voxtype;
          model.name = lib.mkDefault "base";
          service.enable = true;
          settings = {
            hotkey.enabled = false;
            whisper.language = lib.mkDefault "auto";
            audio.feedback = {
              enabled = true;
              theme = "subtle";
              volume = 0.5;
            };
            osd.enabled = false;
            output = {
              # Clipboard paste preserves Unicode with GNOME's ydotool backend.
              mode = "paste";
              paste_keys = "shift+insert";
              fallback_to_clipboard = true;
              notification = {
                on_recording_start = false;
                on_recording_stop = false;
                on_transcription = false;
              };
            };
          };
        };

        systemd.user.services.voxtype.Service.Environment = [
          "YDOTOOL_SOCKET=${ydotoolSocket}"
        ];

        dconf.settings = {
          "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voxtype/"
          ];
          "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/voxtype" = {
            binding = "<Super><Alt>v";
            command = "${lib.getExe voxtype} record toggle";
            name = "Voxtype dictation";
          };
        };
      })
    ];
  };
}
