{pkgs, ...}: {
  services.pipewire.extraConfig.pipewire = {
    "10-mono-mic" = {
      "context.modules" = [
        {
          name = "libpipewire-module-loopback";
          args = {
            "capture.props" = {
              "node.target" = "alsa_input.usb-046d_BRIO_4K_Stream_Edition_D129B03C-02.analog-stereo"; # `pactl list sources`
              "audio.position" = ["FL"]; # Use left channel only; or [ "FL" "FR" ] to average both
            };
            "playback.props" = {
              "node.name" = "mono-brio-mic";
              "node.description" = "Brio Mono Mic";
              "media.class" = "Audio/Source";
              "audio.position" = ["MONO"];
            };
          };
        }
      ];
    };
  };

  environment.systemPackages = with pkgs; [pavucontrol];
}
