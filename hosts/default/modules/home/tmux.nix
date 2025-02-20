{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    mouse = true;
    shortcut = "space";
    terminal = "tmux-256color";
    historyLimit = 50000;
    extraConfig = ''
      set -gq allow-passthrough on
    '';
    plugins = with pkgs.tmuxPlugins; [
      sensible
      tmux-fzf
      catppuccin
      resurrect
      vim-tmux-navigator
    ];
  };
}
