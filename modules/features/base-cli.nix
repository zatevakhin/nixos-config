{...}: {
  flake.nixosModules.base = {
    pkgs,
    lib,
    ...
  }: {
    # NOTE: Will be overridden in `nixvim.nix` if included.
    programs.neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      defaultEditor = true;
    };

    # Default editor
    environment.variables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    # cli tools
    environment.systemPackages = with pkgs; [
      # dev tools
      git
      jq
      tmux
      fzf

      # security
      git-agecrypt
      rage
      sops

      # utilities
      file
      man-pages
      rename
      lsb-release
      bc
      pv
      tldr
      manix
      ripgrep
      eza
      lshw
      unixtools.xxd

      # network tools
      wget
      curl

      # hardware tools
      pciutils
      lm_sensors
      acpi
      pmutils
      usbutils
      dmidecode

      # filesystems
      dust
      ncdu
      lsof

      # monitoring
      fastfetch
      iotop
      iftop

      # processes
      killall

      # filemanagers
      mc

      # Archive tools
      zip
      unzip
      p7zip
    ];
  };
}
