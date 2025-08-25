{
  config,
  pkgs,
  ...
}: {
  boot = {
    # NOTE: Virtual Camera with `v4l2loopback`
    extraModulePackages = with config.boot.kernelPackages; [v4l2loopback];
    extraModprobeConfig = ''
      options v4l2loopback devices=1 video_nr=1 card_label="Virtual Camera" exclusive_caps=1
    '';
  };

  security.polkit.enable = true;

  environment.systemPackages = with pkgs; [
    v4l-utils
  ];
}
