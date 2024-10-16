{pkgs, ...}: {
  programs.tmux = {
    enable = true;
    mouse = true;
    terminal = "screen-256color";
    historyLimit = 10000;
    extraConfig = ''
      set -gq allow-passthrough on
    '';
    plugins = with pkgs.tmuxPlugins; [
      tmux-fzf
      catppuccin
      resurrect
    ];
  };
}
