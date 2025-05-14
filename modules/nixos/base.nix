{pkgs, ...}: {
  imports = [
    ./nix.nix
    ./i18n.nix
    ./sudo.nix
  ];

  environment.systemPackages = with pkgs; [
    # dev tools
    git
    jq
    tmux
    fzf
    sqlite

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
    basez
    libbase58

    # network tools
    wget
    curl
    nmap
    gping

    # hardware tools
    pciutils
    lm_sensors
    acpi
    pmutils
    usbutils
    dmidecode

    # filesystems
    ncdu
    lsof
    ntfs3g
    nfs-utils
    btrfs-progs

    # monitoring
    fastfetch
    iotop
    iftop

    # processes
    killall

    # filemanagers
    mc
  ];

  # Default shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [zsh];

  # Htop with configuration
  programs.htop = {
    enable = true;
    settings = {
      tree_view = 1;
      highlight_base_name = 1;
      shadow_other_users = 1;
      hide_userland_threads = 1;
      hide_kernel_threads = 1;
    };
  };

  # NOTE: Will be overridden in `nixvim.nix` if included.
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
  };

  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
  };
}
