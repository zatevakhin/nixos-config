{...}: let
  dns = "10.0.1.3";
in {
  imports = [
    (args @ {pkgs, ...}: import ./adguard (args // {dns = dns;}))
    (args @ {pkgs, ...}: import ./wg-easy (args // {dns = dns;}))
    (args @ {pkgs, ...}: import ./glance (args // {dns = dns;}))
    ./immich
    ./forgejo
    ./vaultwarden
    ./linkding
    ./variance
    ./searxng
    ./qbittorrent
    ./deep-research
    ./audiobookshelf

    ./grocy
    ./kitchenowl
    #./ntfy
    #./influxdb
    #./restreamer

    # ISSUE: No hardware acceleration for video decoding in mainline ffmpeg.
    #        - https://github.com/edk2-porting/edk2-rk3588/issues/142#issuecomment-2426288640
    #        - https://github.com/jellyfin/jellyfin-ffmpeg/issues/34
    # ./jellyfin

    # Shared containers
    ../../../modules/docker/nodered
    ../../../modules/docker/open-webui

    # Services that don't need an IP
    ./watchtower
  ];
}
