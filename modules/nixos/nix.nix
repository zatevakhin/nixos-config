{pkgs, ...}: {
  nix = {
    # NOTE: Use one (programs.nh.clean.enable or nix.gc.automatic) to avoid conflict.
    # gc = {
    #   automatic = true;
    #   dates = "weekly";
    #   options = "--delete-older-than 14d";
    # };

    package = pkgs.lix;

    optimise = {
      automatic = true;
      dates = ["weekly"];
    };

    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["root" "@wheel"];
    };
  };

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 3";
    clean.dates = "weekly";
  };

  environment.systemPackages = with pkgs; [
    alejandra
  ];
}
