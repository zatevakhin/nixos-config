{pkgs, ...}: {
  environment.systemPackages = with pkgs; [
    devenv
    direnv
  ];
}
