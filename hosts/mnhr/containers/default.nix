{...}: {
  imports = [
    ./wg-easy
    ./immich
    ./forgejo
    ./vaultwarden
    ./linkding
    ./cinny
    ./searxng
    ./deep-research
    ./audiobookshelf
    ./navidrome

    ./grocy
    # ./kitchenowl
    ./ntfy
    ./influxdb
    #./restreamer

    # ISSUE: No hardware acceleration for video decoding in mainline ffmpeg.
    #        - https://github.com/edk2-porting/edk2-rk3588/issues/142#issuecomment-2426288640
    #        - https://github.com/jellyfin/jellyfin-ffmpeg/issues/34
    # ./jellyfin

    ./nodered
    ./open-webui
    ./stump
    ./arr-stack

    # Services that don't need an IP
    ./watchtower
  ];

  services.audiobookshelf-compose = {
    enable = true;
    enable_adguard_rewrite = true;
  };

  services.forgejo-compose = {
    enable = true;
    enable_adguard_rewrite = true;
  };

  services.cinny-compose = {
    enable = true;
    enable_adguard_rewrite = true;
  };

  services.grocy-compose = {
    enable = false;
    enable_adguard_rewrite = true;
  };

  services.deep-research-compose = {
    enable = false;
    enable_adguard_rewrite = true;
  };

  services.stump-compose = {
    enable = true;
    enable_adguard_rewrite = true;
  };

  services.ntfy-compose = {
    enable = true;
    enable_adguard_rewrite = true;
  };

  services.open-webui-compose = {
    enable = true;
    enable_adguard_rewrite = true;
  };

  services.linkding-compose = {
    enable = true;
    enable_adguard_rewrite = true;
    secrets_file = ../secrets/linkding.yaml;
  };

  services.nodered-compose = {
    enable = true;
    enable_adguard_rewrite = true;
  };
}
