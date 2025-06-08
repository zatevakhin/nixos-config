{pkgs, ...}: {
  nix = {
    # NOTE: Use one (programs.nh.clean.enable or nix.gc.automatic) to avoid conflict.
    gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 30d";
    };

    package = pkgs.lix;

    optimise = {
      automatic = true;
      dates = ["monthly"];
    };

    settings = {
      experimental-features = ["nix-command" "flakes" "repl-flake"];
      trusted-users = ["@wheel"];
    };
  };

  programs.nh.enable = true;

  programs.nix-ld = {
    enable = true;
    package = pkgs.nix-ld-rs;
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  environment.systemPackages = with pkgs; [
    alejandra
  ];
}
