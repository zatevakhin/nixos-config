{
  inputs,
  config,
  pkgs,
  lib,
  username,
  ...
}: {
  imports = [
    inputs.nixvim.homeManagerModules.nixvim

    ./modules/home/zsh.nix
    ./modules/home/starship.nix
    ./modules/home/dconf.nix
  ];

  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "${username}";
  home.homeDirectory = "/home/${username}";

  home.sessionVariables = {
    MAMBA_ROOT_PREFIX = "$HOME/.micromamba";
  };

  # <git>
  programs.git = {
    enable = true;
    lfs.enable = true;
    extraConfig = {
      init.defaultBranch = "main";

      pull = {
        rebase = true;
      };
    };
  };
  # </git>

  # <tmux>
  programs.tmux = {
    enable = true;
    mouse = true;
    terminal = "screen-256color";
    historyLimit = 10000;
    plugins = with pkgs.tmuxPlugins; [
      tmux-fzf
      catppuccin
      resurrect
    ];
  };
  # </tmux>

  # <neovim>
  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    colorschemes.gruvbox.enable = true;
    plugins.lualine.enable = true;
  };
  # </neovim>

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.05"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    bat
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
