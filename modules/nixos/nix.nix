{pkgs, lib,  ...}: {
  nix = {
    # NOTE: Use one (programs.nh.clean.enable or nix.gc.automatic) to avoid conflict.
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };

    package = pkgs.lix;

    optimise = {
      automatic = true;
      dates = ["weekly"];
    };

    settings = {
      experimental-features = ["nix-command" "flakes"];
      trusted-users = ["@wheel"];

      extra-substituters = [
        "http://falke.lan:5000?priority=100"
      ];
      trusted-public-keys = [
        "flkr-nix-cache:ZWIXhzptsVZiIUS/P70FFSbGbcZSw/2l5FOsn5itYEA="
      ];
    };
  };
  specialisation = {
    laptop.configuration = {
      system.nixos.tags = ["laptop"];
      nix.settings.extra-substituters = lib.mkForce [];
      nix.settings.trusted-public-keys = lib.mkForce [];
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
