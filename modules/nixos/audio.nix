{pkgs, ...}: {
  services.pulseaudio.enable = false;

  environment.systemPackages = [pkgs.pulseaudioFull];

  services.pipewire = {
    enable = true;

    wireplumber = {
      enable = true;
      extraConfig.bluetoothEnhancements = {
        "monitor.bluez.properties" = {
          "bluez5.enable-hw-volume" = true;
          "bluez5.codecs" = [
            "sbc"
            "sbc_xq"
            "aac"
            "ldac"
            "aptx"
            "aptx_hd"
            "aptx_ll"
            "aptx_ll_duplex"
            "lc3"
          ];
          "bluez5.roles" = [
            "a2dp_sink"
            "a2dp_source"
            "bap_sink"
            "bap_source"
          ];
        };
      };
    };

    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable rtkit for PulseAudio
  security.rtkit.enable = true;
}
