{pkgs, ...}: {
  services.pulseaudio.enable = false;

  environment.systemPackages = [pkgs.pulseaudioFull];

  services.pipewire = {
    enable = true;

    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
  };

  # Enable rtkit for PulseAudio
  security.rtkit.enable = true;
}
