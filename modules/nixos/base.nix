{pkgs, ...}: {
  imports = [
    ./nix.nix
    ./i18n.nix
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

    # utilites
    sudo
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
    nmap

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
    htop
    iotop
    iftop

    # processes
    killall
    mc
  ];

  # Default shell
  programs.zsh.enable = true;
  users.defaultUserShell = pkgs.zsh;
  environment.shells = with pkgs; [zsh];

  # Favorite editor
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
