{pkgs, ...}: {
  systemd.services.aio-startup = let
    device = "Corsair iCUE H100i Elite RGB";
  in {
    description = "${device} startup service";
    wantedBy = ["default.target"];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = [
        "${pkgs.liquidctl}/bin/liquidctl initialize all"
        # NOTE: Seems can't control pump speed
        # "${pkgs.liquidctl}/bin/liquidctl --match '${device}' set pump speed 75"
        "${pkgs.liquidctl}/bin/liquidctl --match '${device}' set fan speed 20 20 30 30 34 50 40 60 50 80"
        "${pkgs.liquidctl}/bin/liquidctl --match '${device}' set led color fixed 350017"
      ];
    };
  };

  environment.systemPackages = with pkgs; [liquidctl];
}
